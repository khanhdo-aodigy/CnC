import { LightningElement, api, track, wire } from "lwc";
import saveFileToRecord from "@salesforce/apex/FileUploadServiceImpl.saveFileToRecord";
import removeFileFromRecord from "@salesforce/apex/FileUploadServiceImpl.removeFileFromRecord";
import getFile from "@salesforce/apex/FileUploadServiceImpl.getFileBySalesAgreementAndType";
import saveFileToRecordCompressedFile from "@salesforce/apex/FileUploadServiceImpl.saveFileToRecordCompressedFile";

import { refreshApex } from "@salesforce/apex";

export default class FileUploadCmp extends LightningElement {
  @api objectName;
  @api recordId;
  @api recordName;
  @api fileNameFormat;
  @api supportedFileType;
  @api label;
  @api apiName;
  @api filePrefix;
  @api displayOnly;

  @track displayMode;
  @track error;
  @track existingAttachment = {};
  @track newAttachment = {};

  @track uploadedFileUrl = "";
  @track fileId;
  initialRender = true;
  uploadAttachment = {};

  renderedCallback() {
    if (this.initialRender) {
      this.displayMode = this.displayOnly === "true" ? true : false;
      this.initialRender = false;
    }
  }

  @wire(getFile, { salesAgreementId: "$recordId", fileType: "$fileNameFormat" })
  existingFile(result) {
    this.wiredResult = result;
    if (result.data) {
      this.existingAttachment = result.data;
      this.fileId = result.data.Id;
      this.uploadedFileUrl = this.getFileURL(this.existingAttachment.Id);
      this.setRemovalAttachmentIcon();
    }
    this.error = result.error ? result.error : undefined;
  }

  onHandleUpload(event) {
    if (event.target.files.length > 0) {
      this.showSpinner();
      this.template.querySelector('div[data-name="addicon"]').style =
        "display: none;";
      this.newAttachment.content = event.target.files[0];
      this.newAttachment.fileName =
        this.fileNameFormat.replace("{RecordName}", this.recordName) +
        "." +
        this.getFileExtension(this.newAttachment.content.name);
      this.processAndCompressAttachment();
    }
  }
  processAndCompressAttachment() {
    const fileReader = new FileReader();
    fileReader.onload = event => {
      const image = new Image();
      image.src = event.target.result;
      image.onload = () => {
        const canvas = document.createElement("canvas");
        const ctx = canvas.getContext("2d");
        const width = 960;
        const height = 960;

        canvas.width = width;
        canvas.height = height;

        canvas.height = canvas.width * (image.height / image.width);

        ctx.drawImage(
          image,
          0,
          0,
          image.width,
          image.height,
          0,
          0,
          canvas.width,
          canvas.height
        ); // canvas.width, canvas.height
        ctx.rotate((90 * Math.PI) / 180);

        //ctx.drawImage(image, 0, 0, width, height);

        //ctx.drawImage(image, 0, 0, width, height);
        const fileURL = canvas.toDataURL(this.newAttachment.content.type);

        this.uploadAttachment = {};
        this.uploadAttachment["fileName"] =
          this.fileNameFormat.replace("{RecordName}", this.recordName) +
          "." +
          this.getFileExtension(this.newAttachment.content.name);
        this.uploadAttachment["contentType"] = this.newAttachment.content.type;
        this.uploadAttachment["Body"] = fileURL.match(/,(.*)$/)[1];
        console.log("===attach====", this.uploadAttachment);
        this.template.querySelector("img").src = fileURL;
        this.sendCompressAttachment();
      };
    };
    fileReader.readAsDataURL(this.newAttachment.content);
  }

  sendCompressAttachment() {
    saveFileToRecordCompressedFile({
      recordId: this.recordId,
      fileName: this.uploadAttachment.fileName,
      prefix: this.filePrefix,
      baseData: encodeURIComponent(this.uploadAttachment.Body)
    })
      .then(result => {
        this.fileId = result.Id;
        this.setRemovalAttachmentIcon();
        refreshApex(this.wiredResult);
      })
      .catch(error => {
        this.error = error;
      });
  }

  onRemoveAttachment() {
    this.showSpinner();

    removeFileFromRecord({ fileRecordId: this.fileId })
      .then(() => {
        this.existingAttachment = {};
        this.uploadedFileUrl = "";
        this.setAddAttachmentIcon();
      })
      .catch(error => {
        this.error = error;
      });
  }

  hideThumbnail() {
    this.template
      .querySelectorAll('div[class="thumbnail"]')
      .forEach(element => {
        element.style = "display: none;";
      });
  }

  showThumbnail() {
    this.template
      .querySelectorAll('div[class="thumbnail"]')
      .forEach(element => {
        element.style = "display: block;";
      });
  }

  showSpinner() {
    let dom = this.template.querySelector('div[data-name="spinner"]');
    dom !== null && (dom.style = "display: block;");

    //this.template.querySelector('div[data-name="spinner"]').style = "display: block;";
  }

  hideSpinner() {
    let dom = this.template.querySelector('div[data-name="spinner"]');
    dom !== null && (dom.style = "display: none;");

    //this.template.querySelector('div[data-name="spinner"]').style= "display: none;";
  }

  setRemovalAttachmentIcon() {
    this.hideSpinner();
    let dom = this.template.querySelector('div[data-name="addicon"]');
    dom !== null && (dom.style = "");
    //this.template.querySelector('div[data-name="addicon"]').style = "";
    this.findDivByClass(
      "div.fileUpload",
      "upload-docs--item with-attachment fileUpload"
    );
    this.showThumbnail();
  }

  setAddAttachmentIcon() {
    let dom = this.template.querySelector('div[data-name="addicon"]');
    dom !== null && (dom.style = "");

    //this.template.querySelector('div[data-name="addicon"]').style = "";
    this.findDivByClass("div.fileUpload", "upload-docs--item fileUpload");
    this.hideThumbnail();
  }

  findDivByClass(searchParam, replaceClassName) {
    this.template.querySelectorAll(searchParam).forEach(element => {
      element.className = replaceClassName;
    });
  }

  getFileExtension(filename) {
    return /[.]/.exec(filename) ? /[^.]+$/.exec(filename)[0] : undefined;
  }

  getFileURL(recordId) {
    return `/sfc/servlet.shepherd/version/download/${recordId}`;
  }
}