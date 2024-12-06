class GlobalVars{
  
  var username;
  var code;
  var id;
  var company;

  GlobalVars create(String username, String code, String id, String company){
    var globalVars = GlobalVars();
    globalVars.username = this.username; 
    globalVars.code = this.code; 
    globalVars.id = this.id; 
    globalVars.company = this.company; 
    return globalVars;
  }


}