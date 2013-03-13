app.factory('datacontext',['$http','host','logger','model',
function($http, host, logger, model) {
  var log = logger.log;

  log("creating datacontext");
  configureBreeze();

  var serviceName = host + '/api/' + 'codecamper';
  var manager = new breeze.EntityManager(serviceName);
  model.initialize(manager.metadataStore);

  plunkerHelpers.isCorsCapable();
  var datacontext = {
      getItems: getItems
  };
  return datacontext;



  /***  supporting functions ***/

function getItems(searchText,stayLocal) {

    var query = breeze.EntityQuery.from("Speakers")
        .expand('speakerSessions')
        .orderBy('firstName, lastName');

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

    return Q.delay(delayMs).then(function() {
        return manager.executeQuery(query)
            .then(getSucceeded)
            .fail(getFailed);
        });
  }

  function getSucceeded(data) {
      log("retrieved " + data.results.length);
      return data.results;
  }


  function getFailed(error) {
      log("query failed: " + error.message);
      throw error; // so caller can hear it
  }


  function configureBreeze() {
    // configure to use the model library for Angular
    breeze.config.initializeAdapterInstance("modelLibrary", "backingStore", true);
    // configure to use camelCase
    breeze.NamingConvention.camelCase.setAsDefault();
  }
}]);