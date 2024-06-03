({
    showToast : function() {
        var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "success",
                    "title": "¡Atencion!",
                    "message": "Se ha creado correctamente el registro."
                });
        toastEvent.fire();
    }
})