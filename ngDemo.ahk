;===================================================================
; Angular / Breeze Demo
; 12 March 2013  Angular Meetup, Mt. View
;===================================================================

;*********************************************************************
; Add base index.html
;*********************************************************************

::ngicreate:: 
clipboard=
(
<!DOCTYPE html>
<html >  
  <head lang="en">
    <meta charset="utf-8">
    <title>Breeze/Ng Sample</title>  
    <!-- Breeze local: http://localhost:63428  remote: http://sampleservice.breezejs.com -->	   
    <link rel="stylesheet" href="http://sampleservice.breezejs.com/content/styles.css">  	
  </head>
  
  <body id="view" data-ng-app="app" data-ng-controller="MainCtrl" class="ng-cloak">
    <h1>Breeze/Ng Sample</h1>
    <label class="error" data-ng-show="errorMessage">{{errorMessage}}</label>	
	
	<!-- I'm using a table ... so shoot me! -->
	<table><tr><td style="vertical-align: top; min-width:10em"> 
    <h3>Data:</h3>
    <ul class=items>
      <li data-ng-repeat="item in items">
            Bind to item.something
      </li>
    </ul>
	
    </td><td style="vertical-align: top;">
    <h2>Log:</h2>
    <ol id="log" type="1">
      <li data-ng-repeat="log in logList">{{log}}</li>
    </ol>
	
	</td></tr></table>
    <p>
        <a href="http://www.breezejs.com" target="_blank">Breeze Home</a>
    </p>
    <!-- 3rd party libs -->
    <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.9.0/jquery.js"></script>
    <script src="http://sampleservice.breezejs.com/scripts/q.min.js"></script>
    <script src="http://sampleservice.breezejs.com/scripts/breeze.min.js"></script>
    <script src="http://sampleservice.breezejs.com/scripts/plunkerHelpers.js"></script>
    <script src="http://ajax.googleapis.com/ajax/libs/angularjs/1.0.3/angular.min.js"></script>
        
    <!-- app libs -->
    <script>
      document.write('<base href="' + document.location + '" />');
    </script>
    <script src="app.js"></script>
    <script src="datacontext.js"></script>
    <script src="http://sampleservice.breezejs.com/scripts/ngLogger.js"></script>	
  </body>
</html>
)
send ^v
return
;*********************************************************************
; Add base 'app' module and 'MainCtrl' controller
;*********************************************************************
::ngacreate:: 
clipboard=
(
var app = angular.module('app', []);

  app.value('host', false /*use local host*/ ?
    "http://localhost:63428" :
    "http://sampleservice.breezejs.com");

	app.controller('MainCtrl',
	['$scope', 'logger', 'datacontext',
	function($scope, logger, datacontext) {
        logger.log('created MainCtrl');
        $scope.items = [];	
        $scope.logList = logger.logList;
		$scope.lastLog = function(){return logger.lastLog;};

	}]);
)
send ^v
return	
;*********************************************************************
; Add base 'datacontext' for app module
;*********************************************************************
::ngdcreate:: 
clipboard=
(
app.factory('datacontext',['$http','host','logger',  
function($http, host, logger) {
  var log = logger.log;
  
  log("creating datacontext");
  configureBreeze();

  var serviceName = host + '/api/' + 'codecamper'; 
  var manager = new breeze.EntityManager(serviceName);

  plunkerHelpers.isCorsCapable();
  var datacontext = {
      getItems: getItems
  };
  return datacontext;
  

  
  /***  supporting functions ***/ 
  
  function getItems() {
      // dummy implementation
      return Q.resolve([]);
  }
  
  
  function configureBreeze() {
    // configure to use the model library for Angular
    breeze.config.initializeAdapterInstance("modelLibrary", "backingStore", true);
    // configure to use camelCase
    breeze.NamingConvention.camelCase.setAsDefault();
  }  
}]);
)
send ^v
return	
;*********************************************************************
; app controller getItems
;*********************************************************************
::ngaget:: 
clipboard=
(
  getItems();
  
  /***  supporting functions ***/  
  
  function getItems() {
    datacontext.getItems()
               .then(success)
               .fail(failed)
               .fin(refreshView); 
  }           
  function success(data) {
      $scope.items = data;
  }
  function failed(error) {
      $scope.errorMessage = error.message;
  }
  function refreshView() {
      $scope.$apply();
  }
)
send ^v
return	
;*********************************************************************
; datacontroller dummy getItems
; bind with {{item.FirstName}} {{item.LastName}}
;*********************************************************************
::ngdget:: 
clipboard=
(
   function getItems() {
      // dummy implementation: bind to {{item.name}}
      return Q.resolve(
              {results:[
                {LastName:"Minar", FirstName: "Igor"},
                {LastName:"Black", FirstName: "Naomi"}]
              })
              .then(getSucceeded)
              .fail(getFailed);
  }

  function getSucceeded(data) {
      log("retrieved " + data.results.length);
      return data.results;
  }
  function getFailed(error) {
      log("query failed: " + error.message);
      throw error; // so caller can hear it
  }
)
send ^v
return	
;*********************************************************************
; index: bind to {{item.FirstName}} {{item.LastName}}
;*********************************************************************
::ngibind:: 
clipboard=
(
       {{item.FirstName}} {{item.LastName}}
)
send ^v
return		
;*********************************************************************
; datacontroller $http
; replace BOTH getItems and getSucceeded
;*********************************************************************
::ngd$http:: 
clipboard=
(
function getItems() {

  var ngPromise = $http.get(serviceName+"/speakers");
	
  return Q.when(ngPromise)
        .then(getSucceeded)
        .fail(getFailed);
  }

  function getSucceeded(data) {
      log("retrieved " + data.data.length);
      return data.data;
  }
  
)
send ^v
return
;*********************************************************************
; datacontext: simple Breeze speakers query
; replace BOTH getItems and getSucceeded
; bind with {{item.firstName}} {{item.lastName}} <-- camelCase !!
;*********************************************************************
::ngdspeakers:: 
clipboard=
(  
  var query = breeze.EntityQuery.from("Speakers");

  return manager.executeQuery(query)
        .then(getSucceeded)
        .fail(getFailed);
  }

  function getSucceeded(data) {
      log("retrieved " + data.results.length);
      return data.results;
  }

)
send ^v
return
;*********************************************************************
; index.html - add search textbox
; replace BOTH getItems and getSucceeded
;*********************************************************************
::ngisearch::
clipboard=
(  

    <p>Search: <input data-ng-model="searchText" /> {{searchText}}
    <span data-ng-bind="lastLog()" class="message"></span></p>
	
)
send ^v
return
;*********************************************************************
; app - add search to $scope
;*********************************************************************
::ngasearch::
clipboard=
(  
    $scope.searchText = "";
    $scope.$watch('searchText', getItems);
)
send ^v
return	
;*********************************************************************
; add search criteria to datacontext
; remember to put searchText in the SIGNATURE
;*********************************************************************
::ngdsearch:: 
clipboard=
(  
  //Add searchText as last param of getItems
  // Both HERE and in APP.JS
  if (searchText && (searchText = searchText.trim())) {
    log("searching for " + searchText);
    query = query.where('lastName', 'contains', searchText);
  } else {
    log("getting all");
  }

)
send ^v
return
;*********************************************************************
; datacontext: Predicate search in firstName or lastName
;*********************************************************************
::ngdpred:: 
clipboard=
( 
    var pred = breeze.Predicate
        .create('lastName', 'contains', searchText)
           .or('firstName', 'contains', searchText);

    query = query.where(pred);
)
send ^v 
return	
;*********************************************************************
; datacontext: slow getItems down
;*********************************************************************
::ngdslow:: 
clipboard=
(  
    return Q.delay(1000).then(function() {
        return manager.executeQuery(query)
            .then(getSucceeded)
            .fail(getFailed);
        });

)
send ^v 
return 
;*********************************************************************
; In controller (app) delay search while typing
;*********************************************************************
::ngadelay::
clipboard=
(  
  var oldSearchText;

  // wait until user stops typing (searchText === oldSearchText)
  function delayedSearch(newVal, oldVal){
    if ($scope.searchText === oldSearchText)  {
      getItems();
      oldSearchText = null;
    } else if (newVal !== oldVal) { // if not init phase
      oldSearchText = newVal;
      $timeout(delayedSearch, 800);
    }
  }
)
send ^v 
return
;*********************************************************************
; index: Add "stayLocal" checkbox above search
;*********************************************************************
::ngistaylocal::
clipboard=
(
    <p>Stay local: <input type='checkbox' data-ng-model="stayLocal" /> 
)
send ^v 
return	
;*********************************************************************
; app control: Add stayLocal to $scope
;*********************************************************************
::ngastaylocal::
clipboard=
(
    $scope.stayLocal = false;
    $scope.$watch('stayLocal', function(newVal, oldVal) {
      if (newVal !== oldVal) { // if not init phase
        getItems(); 
      } 
    });
)
send ^v 
return	
;*********************************************************************
; datacontext: Add local query option inside getItems
; Replaces "if (searchText) ..." block
; Add stayLocal as last param of getItems
;*********************************************************************
::ngdstaylocal::
clipboard=
(  
    //Add stayLocal as last param of getItems
    // in BOTH app.js and datacontext.js
    var locally = stayLocal ? " locally" : " remotely";
    var delayMs = 800;
    if (stayLocal) {
      query = query.using(breeze.FetchStrategy.FromLocalCache);
      locally = " locally";
      delayMs = 0;
      manager.metadataStore.setEntityTypeForResourceName("Speakers", "Person");
    } else {
      locally = " remotely";
    }

    if (searchText && (searchText = searchText.trim())) {
      log("searching for " + searchText + locally);
      var pred = breeze.Predicate
          .create('lastName', 'contains', searchText)
             .or('firstName', 'contains', searchText);

      query = query.where(pred);
    } else {
      log("getting all"+locally);
    }
    // change Q.delay(1000) to Q.delay(delayMs)
)
send ^v 
return  
;*********************************************************************
; index: show speakers expanded with sessions
; replace speaker listing with this
;*********************************************************************
::ngiexpand::
clipboard=
( 
    <ul class=items>
      <li data-ng-repeat="item in items">
         {{item.firstName}} {{item.lastName}}
         <ul>
           <li data-ng-repeat="session in item.speakerSessions">
               Session: {{session.title}}
           </li>
         </ul>
      </li>
    </ul>
	
)
send ^v 
return 
;*********************************************************************
; model: create model.js
;*********************************************************************
::ngmcreate::
clipboard=
( 
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
)
send ^v 
return 
;*********************************************************************
; index: show fullName with Fn/Ln input
; replaces {{item.firstName}} {{item.lastName}}
;*********************************************************************
::ngifullname::
clipboard=
( 
    <input data-ng-model="item.firstName" data-ng-class="{isDirty:item.isDirty()}"/>
    <input data-ng-model="item.lastName"  data-ng-class="{isDirty:item.isDirty()}"/>
    <span data-ng-bind="item.fullName()"  data-ng-class="{isDirty:item.isDirty()}"></span>
)
send ^v 
return 