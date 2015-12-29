//给每张img添加点击事件
function setImageClickFunction(){
  var imgs = document.getElementsByTagName("img");
  for (var i=0;i<imgs.length;i++){
    var src = imgs[i].src;
    imgs[i].setAttribute("onClick","change_pic(src)");
  }
  document.location = imageurls;
}

//点击图片后返回给OC的回调函数
function change_pic(imagesrc){
  var url = imagesrc;
//  window.open("www.baidu.com")
  document.location = url;
}