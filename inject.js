document.querySelectorAll('input[type=password]')[1].addEventListener("focus", function(e) {
   var id = e.target.id;
   if (!id) { id = 'the_active_id'; e.target.id = id; }
   console.log('focusing, id is now: ', id);
   window.location.href = 'myapp://hello?id=' + id;
}, true);

