({
    searchIconClicked : function(component, event, helper) {
        console.log('@@---->>>>');
        console.log(jQuery('#SearchIcon').closest('.cHeaderWrapper--fixed'));
        /*window.setTimeout(
            $A.getCallback(function() {
                console.log(document.getElementsByClassName("cHeaderTopInternalWrapper"));
            }), 5000
        );*/
        
    }
})