import { LightningElement, api, wire, track } from 'lwc';
import getConfigByPS from '@salesforce/apex/ProcessBarUtil.getConfigByPS';
import updateSalesAgreement from '@salesforce/apex/DigitalSalesAgreementApplication.updateSalesAgreement';

export default class Dsa_processFlowHeader extends LightningElement {

    @api processType;
    @api currentStep;
    @api recordId;
    @api showOnlyReview = false;
    @track processSteps;
    @track error;
    @track changeList={};

    @track stepSequence = [];
    initialRender = true;

    @api
    updateChangeList(changeList){
        this.changeList = changeList;
    }

    @api setCurrentStage(currentStep){
        this.currentStep = currentStep;
        this.processingStepIcon();
    }

    renderedCallback(){
        if(this.initialRender && this.stepSequence.length > 0){
            this.processingStepIcon();
            this.initialRender = false;
        }
    }

    @wire(getConfigByPS, { processType: '$processType' }) wir2edprocessSteps({ error, data }) {
        if (data) {

            this.stepSequence = data.map(processStep => {return processStep.Process_Path_Label__c});
            this.processSteps = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.processSteps = undefined;
        }
    }

    onSaveExit() {
        if(this.showOnlyReview===true) return;
        Object.keys(this.changeList).forEach(key => this.changeList[key] == null && delete this.changeList[key]);
        this.changeList.Id = this.recordId;
        if(this.changeList.Id){
            //this.changeList.Last_save_on_form__c = this.currentStage;
            updateSalesAgreement({salesAgreement : this.changeList }).then(result=>{
                console.log('Update successfully' + result);
                this.dispatchEvent(new CustomEvent('closewindow'));
                //window.close();
            }).catch(error=>{
                console.log('Update failed ' + error);
            })
        }

        console.log(JSON.stringify(this.changeList));
    }

    onSelectStep(event){
        if(this.showOnlyReview === true)return;
        const eventData = { stage : event.currentTarget.name };
        this.currentStep = event.currentTarget.name;
        //console.log(JSON.stringify(eventData));
        this.processingStepIcon();
        this.fireEventToApp(eventData);
    }

    onSelectBack(){
        if(this.showOnlyReview===true) return;
        const backStep = this.stepSequence[this.stepSequence.indexOf(this.currentStep)-1];
        this.dispatchEvent(new CustomEvent('activitychanged', { detail: {stage : backStep} }));
    }

    fireEventToApp(eventData){
        this.dispatchEvent(new CustomEvent('activitychanged', { detail: eventData }));
    }

    processingStepIcon(){
        this.currentStep = this.showOnlyReview === true ? 'Review' : this.currentStep;
        const currentIndex = this.stepSequence.indexOf(this.currentStep);

        for (let i = 0; i < this.stepSequence.length; i++) {
            i < currentIndex && this.setTickMarkForStages(this.stepSequence[i]);
            i === currentIndex && this.setCurrentMarkForStage(this.stepSequence[i]);
            i > currentIndex && this.setDefaultMarkForStage(this.stepSequence[i]);
        }
    }

    setTickMarkForStages(stage){
        this.template.querySelector(`div[name='${stage}'] small[name="tickIcon"]`).style.display = 'block';
        this.template.querySelector(`div[name='${stage}'] big[name="activeIcon"]`).style.display = 'none';
        this.template.querySelector(`div[name='${stage}'] span`).style.display = 'none';
    }

    setCurrentMarkForStage(stage){
        this.template.querySelector(`div[name='${stage}'] small[name="tickIcon"]`).style.display = 'none';
        this.template.querySelector(`div[name='${stage}'] big[name="activeIcon"]`).style.display = 'block';
        this.template.querySelector(`div[name='${stage}'] span`).style.display = 'block';
        this.template.querySelector(`div[name='${stage}'] span`).style.border = 0;
        this.template.querySelector(`div[name='${stage}'] span`).style.background = 'transparent';
    }

    setDefaultMarkForStage(stage){
        this.template.querySelector(`div[name='${stage}'] big[name="activeIcon"]`).style = "";
        this.template.querySelector(`div[name='${stage}'] small[name="tickIcon"]`).style = "";
        this.template.querySelector(`div[name='${stage}'] span`).style = "";
    }

}