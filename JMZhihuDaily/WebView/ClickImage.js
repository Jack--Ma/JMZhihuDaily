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

