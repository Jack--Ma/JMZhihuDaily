//给每张img添加点击事件
function set_image_click_function() {
  var imgs = document.getElementsByTagName("img");
  for (var i=0; i<imgs.length; i++) {
    var src = imgs[i].src;
    imgs[i].setAttribute("onClick","click_image(src)");
  }
  document.location = imageurls;
}

//点击图片后返回给OC的回调函数
function click_image(imagesrc) {
  var url = imagesrc;
  document.location = url;
}

//夜间模式下改变字体与背景颜色
function change_color() {
  //标题
  var title = document.getElementsByTagName("h2");
  title[0].style.color = "white";
  
  //作者及签名
  var author = document.getElementsByTagName("span");
  author[0].style.color = "#AAAAAA";
  author[1].style.color = "#AAAAAA";
 
  //正文
  var texts = document.getElementsByTagName("p");
  for (var i = 0; i < texts.length; i++) {
    texts[i].style.color = "#AAAAAA";
  }
  
  //背景颜色
  var webBackground = document.getElementsByTagName("div");
  webBackground[0].style.backgroundColor = "#34333C"
  document.body.style.backgroundColor = "#34333C";
}
