({
    init : function (cmp) {
        var flow = cmp.find("flowData");
        var accId = cmp.get("v.accid") != null ? cmp.get("v.accid") : '';
        var conId = cmp.get("v.conid") != null ? cmp.get("v.conid") : '';
        var inputVariables = [{name:"AccId", type:"String", value:accId},
                              {name:"ContId", type:"String", value:conId}]
        flow.startFlow("CreateOpportunityNew", inputVariables);
    },

    statusChange : function (cmp, event) {
        console.log('Status Change' + event);
        if (event.getParam('status') === "FINISHED") {
            var outputVariables = event.getParam('outputVariables');
            debugger;
            var flowName = outputVariables[0].flowName;
            console.log(outputVariables);
            for (var i=0; i<outputVariables.length;i++) {
                if (outputVariables[i].name == 'OppId') {
                    var oppId = outputVariables[i].value;                    
                }
                if (outputVariables[i].name == 'Is_Partner_Deal') {
                    var isPartner = outputVariables[i].value;                    
                }
                if (outputVariables[i].name == 'AccId') {
                    var accId = outputVariables[i].value;
                }
                if (outputVariables[i].name == 'ContId') {
                    var conId = outputVariables[i].value;                    
                }
            }
            if(conId == null && accId != null){
                location.href = '/' + accId;
            } else if (accId == null && conId != null){
                location.href = '/' + conId;
            } else if(conId == null && accId == null){
                location.href = '/lightning/page/home';
            } else if (flowName == 'CreateOpportunityNew') {
                console.log(oppId);
                if (isPartner == true) {
                    location.href = 'apex/Attach_Partner_Page?OppID='+oppId;
                } else {
                    location.href = '/'+oppId;
                }
            }
        }
    }
})