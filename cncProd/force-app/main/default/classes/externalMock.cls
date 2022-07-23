global class externalMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response.
        // Set response values, and 
        // return response.
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        //res.setBody('{"BookingDtlResponse": [{"recordid": "766754","RegistrationNo": "SLU7079A","OwnerID": "6235ad79-4eb6-4212-b281-3b1239782b66","CustomerName": "Testing","MobileNo": "61234567","BookingType": "Internet","AppointmentDate": "2019-01-11T08:30:00","AppointmentTime": "1/11/2019 8:30:00 AM","ServiceCode": "EMBLUB","Location": "MBEL","Remarks": "Testing 123","CSERemarks": null,"Status": "Booked","DOK": "0","PKD": "0","PKDTime": null,"Mileage": null,"AdditionalJobsDesc": null,"CreatedDate": "2019-01-08T12:02:04","CreatedTime": "2019-01-08T12:02:04","CreatedBy": "Internet","LastEdittedDate": "2019-01-11T07:30:04","LastEdittedBy": null,"LastEdittedTime": "2019-01-11T07:30:04","PickupLocation": null,"ReturnLocation": null,"ChassisNo": null,"WIP_NO": null,"ServiceCategory": "Regular Service & Repair","ServiceCodeDesc": "Lubrication Service","CancelledBy": null,"CancelledDatetime": "0001-01-01T00:00:00"},{"recordid": "151199","RegistrationNo": "124124","OwnerID": "7be995ee-1b6d-4b6d-9588-f98827af74d0","CustomerName": "Testing","MobileNo": "61234567","BookingType": "Internet","AppointmentDate": "2019-03-11T08:30:00","AppointmentTime": "3/11/2019 8:30:00 AM","ServiceCode": "EMBLUB","Location": "MBEL","Remarks": "Testing 123","CSERemarks": null,"Status": "Booked","DOK": "0","PKD": "0","PKDTime": null,"Mileage": null,"AdditionalJobsDesc": null,"CreatedDate": "2019-03-07T11:06:34","CreatedTime": "2019-03-07T11:06:34","CreatedBy": "Internet","LastEdittedDate": "0001-01-01T00:00:00","LastEdittedBy": null,"LastEdittedTime": "0001-01-01T00:00:00","PickupLocation": null,"ReturnLocation": null,"ChassisNo": null,"WIP_NO": null,"ServiceCategory": "Regular Service & Repair","ServiceCodeDesc": "Lubrication Service","CancelledBy": null,"CancelledDatetime": "0001-01-01T00:00:00"} ],"Message": "The operation is completed successfully. 2 bookings have been retrieved . "}');
        res.setBody('{"data":{},"error":{"code":304,"message":"Invalid bookingId"}}');
        res.setStatusCode(200);
        return res;
    }
}