var app = angular.module('app', []);

app.value('host', false /*use local host*/ ?
          "http://localhost:63428" :
          "http://sampleservice.breezejs.com");

app.controller('MainCtrl',
['$scope', 'logger', 'datacontext','$timeout',
function($scope, logger, datacontext, $timeout) {
    logger.log('created MainCtrl');
    $scope.items = [];
    $scope.logList = logger.logList;
    $scope.lastLog = function(){return logger.lastLog;};
    $scope.searchText = "";
    $scope.$watch('searchText', delayedSearch);
    $scope.stayLocal = false;
    $scope.$watch('stayLocal', function(newVal, oldVal) {
      if (newVal !== oldVal) { // if not init phase
        getItems();
      }
    });

    getItems();

  /***  supporting functions ***/
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

  function getItems() {
    datacontext.getItems($scope.searchText, $scope.stayLocal)
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
}]);