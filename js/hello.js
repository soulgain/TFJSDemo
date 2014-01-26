/**
 *
 */


function getLoginVerificationCode() {
    
    return http.getStream(JSON.stringify({
                                         "waitDesc" : "准备登录中...",
                                         "method" : "POST",
                                         "url" : "https://kyfw.12306.cn/otn/passcodeNew/getPassCodeNew?module=login&rand=sjrand",
                                         "data" : {
                                         }
                                         }));
}

function login(username, passowrd, verifyCode) {
    
    var request = JSON.stringify({
                                 "waitDesc" : "准备登录中...",
                                 "method" : "POST",
                                 "url" : "https://kyfw.12306.cn/otn/login/loginAysnSuggest",
                                 "referer" : "https://kyfw.12306.cn/otn/login/init",
                                 "data" : {
                                 "loginUserDTO.user_name" : username,
                                 "userDTO.password" : passowrd,
                                 "randCode" : verifyCode,
                                 "form" : "loginEncForm"
                                 }
                                 });
    
    var response = http.sendRequest(request);
    var result = JSON.parse(response);
    var errorMessage = result.messages[0];
    
    if (errorMessage != null) {
        return errorMessage;
    }
    
//    var request = JSON.stringify({
//                                 "waitDesc" : "努力登录中...",
//                                 "method" : "POST",
//                                 "url" : "https://kyfw.12306.cn/otn/login/userLogin",
//                                 "referer" : "https://kyfw.12306.cn/otn/login/init",
//                                 "data" : {
//                                 "_json_att" : ""
//                                 }
//                                 });
//    
//    var html = http.sendRequest(request);
    // var loginName = dom.selectNodeText(html,
    // "//a[@id='login_user']/span/text()");
    
    var request = JSON.stringify({
                                 "waitDesc" : "还在登录，请稍候...",
                                 "method" : "GET",
                                 "url" : "https://kyfw.12306.cn/otn/modifyUser/initQueryUserInfo"
                                 });
    var html = http.sendRequest(request);
    var userForm = dom.selectNodeSet(html, "//form[@id='modifyUserForm']//input");
    
    var realName = dom.selectNodeText(userForm, "//input[@name='userDTO.loginUserDTO.name']/@value");
    var email = dom.selectNodeText(userForm, "//input[@name='userDTO.email']/@value");
    var mobile = dom.selectNodeText(userForm, "//input[@name='userDTO.mobile_no']/@value");
    var loginName = dom.selectNodeText(userForm, "//input[@name='userDTO.loginUserDTO.user_name']/@value");
    
    var m = userForm.match(/(is_active)(.+?)value/);
//    log(m[0]);
    
    return JSON.stringify({
                          "errorMessage" : errorMessage,
                          "data" : {
                          "realName" : realName,
                          "email" : email,
                          "mobile" : mobile,
                          "loginName" : loginName
                          }
                          });
}

function queryTickets(from, to, date) {
    
    var response = http.sendRequest(JSON.stringify({
                                                   "waitDesc11" : "正在搜索余票...",
                                                   "method" : "GET",
                                                   "url" : "https://kyfw.12306.cn/otn/leftTicket/query",
                                                   "referer" : "https://kyfw.12306.cn/otn/leftTicket/init",
                                                   "data" : {
                                                   "leftTicketDTO.train_date" : date,
                                                   "leftTicketDTO.from_station" : from,
                                                   "leftTicketDTO.to_station" : to,
                                                   "purpose_codes" : "ADULT"
                                                   }
                                                   }));
    
    return response;
}
