public without sharing class MB_TestDrivePDFCtrl {
    public Vehicle_Request__c request { get; set; }
    public String custAddress { get; set; }

    public MB_TestDrivePDFCtrl() {
        string reqId = ApexPages.currentPage().getParameters().get('id');
        request = VehicleRequestService.getTestDriveById(reqId)[0];
        formatAddress(request);
    }

    public void formatAddress(Vehicle_Request__c request) {
        if (String.isNotBlank(request.Account__r.Address_Line_1__pc)) {
            custAddress = request.Account__r.Address_Line_1__pc;
        }
        if (String.isNotBlank(request.Account__r.Address_Line_2__pc)) {
            custAddress = custAddress != '' ? custAddress + ', ' + request.Account__r.Address_Line_2__pc : request.Account__r.Address_Line_2__pc;
        }
        if (String.isNotBlank(request.Account__r.Address_Line_3__pc)) {
            custAddress = custAddress != '' ? custAddress + ', ' + request.Account__r.Address_Line_3__pc : request.Account__r.Address_Line_3__pc;
        }
        if (String.isNotBlank(request.Account__r.Address_Line_4__pc)) {
            custAddress = custAddress != '' ? custAddress + ', ' + request.Account__r.Address_Line_4__pc : request.Account__r.Address_Line_4__pc;
        }
        if (String.isNotBlank(request.Account__r.Unit_No_Floor__pc)) {
            custAddress = custAddress != '' ? custAddress + ', ' + request.Account__r.Unit_No_Floor__pc : request.Account__r.Unit_No_Floor__pc;
        }
        if (String.isNotBlank(request.Account__r.Country__pc)) {
            custAddress = custAddress != '' ? custAddress + ', ' + custAddress + ', ' + request.Account__r.Country__pc : request.Account__r.Country__pc;
        }
    }
}