function sendmsg(msg) {
  mdui.snackbar({
    message: msg,
    position: "top",
  });
}

function done() {
  mdui.mutation()
  mdui.updateTextFields()

  $("#loading").remove();
  $("#view").removeAttr("style");
}

function adminBanner() {
  $.ajax({
    method: "GET",
    url: "/ajax/userInfo",
    dataType: "json",
  })
    .done(function (response) {
      if (response.Ok) {
        if (response.Data.permission == 2) {
          $("#admin_banner").removeAttr("style");
        }
      } else sendmsg(response.Msg);
    })
    .fail(function () {
      sendmsg("未能获取服务器数据, 请检查网络是否正常");
    });
}

function compareTime(time1, time2) {
  var t1 = new Date(time1)
  var t2 = new Date(time2)

  if (t1.getTime() > t2.getTime()) {
    return true
  }

  return false;
}