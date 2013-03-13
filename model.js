/* model */
app.factory('model', function() {

    extendModel();

    var model = {
        initialize: initialize
    };

    return model;

    //#region private members
    function initialize(metadataStore) {
        metadataStore.registerEntityTypeCtor("Person", Person);
    }

    function Person() {
    	this.firstName = "Ima";   // defaults
    	this.lastName ="Noobie";
    }

    function extendModel() {
    	Person.prototype.fullName = function() {
    	    return this.firstName + " " + this.lastName;
        };
        Person.prototype.isDirty = function() {
        	return !this.entityAspect.entityState.isUnchanged();
        };
    }
    //#endregion
});