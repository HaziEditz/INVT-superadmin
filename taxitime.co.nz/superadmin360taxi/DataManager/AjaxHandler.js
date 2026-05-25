var  ret;
function Selector(param, proc) {
    var url = "DataManager/Data.aspx/DataSelector";
   
    return $.ajax({
        url: url,
        type: "POST",
        datatype: "json",
        data: JSON.stringify({
            "data": param,
            "action": proc
        }),
        contentType: "application/json; charset=utf-8",
        success: function (data) {
            ret = data;
        },
        async:true,
        error: errorFn
    });
    
}
function Selector1(param, proc) {
    var url = "DataManager/Data.aspx/DataSelectorLess";
    return $.ajax({
        url: url,
        type: "POST",
        datatype: "json",
        data: JSON.stringify({
            "data": param,
            "action": proc
        }),
        contentType: "application/json; charset=utf-8",
        success: function (data) {
            ret = data;
            
        },
        async: true,
        error: errorFn
    });

}
function Action(param,proc) {
    var url = "DataManager/Data.aspx/DataProcessor";
   return $.ajax({
        url: url,
        type: "POST",
        datatype: "json",
        data: JSON.stringify({
            "data": param,
            "action": proc
        }),
        contentType: "application/json; charset=utf-8",
        success: function (data) {
            SuccMessage(data.d);
           
        },
        error: errorFn
       
   });
}
function ActionCheck(param, proc) {
    var url = "DataManager/Data.aspx/DataProcessor";
    return $.ajax({
        url: url,
        type: "POST",
        datatype: "json",
        data: JSON.stringify({
            "data": param,
            "action": proc
        }),
        contentType: "application/json; charset=utf-8",
        success: function (data) {
           
            Result(data.d);

        },
        error: errorFn

    });
}

function ActionDelete(param, proc)
{
    var url = "DataManager/Data.aspx/DataProcessor";
    return $.ajax({
        url: url,
        type: "POST",
        datatype: "json",
        data: JSON.stringify({
            "data": param,
            "action": proc
        }),
        contentType: "application/json; charset=utf-8",
        success: function (data) {
            SuccMessage(data.d);
            if (data.d == "Operation Successfully Performed") {
                FnRowDelete();

            }
        },
        error: errorFn

    });
}
function ActionNewRecord(param, proc,Status) {
    var url = "DataManager/Data.aspx/DataProcessor";
    return $.ajax({
        url: url,
        type: "POST",
        datatype: "json",
        data: JSON.stringify({
            "data": param,
            "action": proc
        }),
        contentType: "application/json; charset=utf-8",
        success: function (data) {
            SuccMessage(data.d);
                if (data.d == "Operation Successfully Performed" && Status == "Retrieve") {

                    FnNewRecord();

                }
        },
        error: errorFn

    });
}

function Action1(param,col,arry,proc,FnName) {
    var url = "DataManager/Data.aspx/DataProcessor1";
    return $.ajax({
        url: url,
        type: "POST",
        datatype: "json",
        data: JSON.stringify({
            "data": param,
            "colms": col,
            "Details":arry,
            "action": proc
        }),
        contentType: "application/json; charset=utf-8",
        success: function (data) {
            SuccMessage(data.d);
            if (data.d == "Operation Successfully Performed" && FnName == "Retrieve")
            {
                FnNewScedule();
            }
           

        },
        error: errorFn
    });
}
function ActionDetails(param, col, arry1,arry2,arry3, proc, FnName) {
    var url = "DataManager/Data.aspx/DataProcessor2";
    return $.ajax({
        url: url,
        type: "POST",
        datatype: "json",
        data: JSON.stringify({
            "data": param,
            "colms": col,
            "PDetails": arry1,
            "CDetails": arry2,
            "EDetails": arry3,
            "action": proc
        }),
        contentType: "application/json; charset=utf-8",
        success: function (data) {
            SuccMessage(data.d);
            if (data.d == "Operation Successfully Performed" && FnName == "Retrieve") {
                FnNewRecord();
            }


        },
        error: errorFn
    });
}
function errorFn(err, status, xhr) {
    //ErrMessage(status.toUpperCase() + "! " + xhr);
    ErrMessage("Error, Contact the adminstration for the correction");
}

function ActionSignUp(param, Password, proc, Status) {
    var url = "DataManager/Data.aspx/DataProcessorSignUp";
    return $.ajax({
        url: url,
        type: "POST",
        datatype: "json",
        data: JSON.stringify({
            "data": param,
            "Password": Password,
            "action": proc
        }),
        contentType: "application/json; charset=utf-8",
        success: function (data) {

            if (data.d == "Operation Successfully Performed" && Status == "Retrieve") {
                toastr["success"](data.d, 'Message!');
                FnNewRecord();

            }
            else if (data.d == "Operation Successfully Performed" && Status != "Retrieve") {
                toastr["success"](data.d, 'Message!');
            }
            else if (data.d == "Your Information Added Successfully,A Verfication Email Has Been Sent To The Email" && Status == "No") {
               // $("#myModal").modal('show');
                toastr["success"]("You have successfully registered a new company.", 'Success Message!');
            }
            else if (data.d == "Transaction Rolled Back!")
            {
                toastr["error"]("Opps, Something went wrong, Contact the developers.", 'Error Message!');
            }
            //Result(data.d);

        },
        error: errorFn

    });
}
