<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<title>Document</title>
	<link href="css/normalize.css" rel="stylesheet">
   	<link href="css/bootstrap.min.css" rel="stylesheet">
   	<script src="js/jquery-2.1.3.js"type="text/javascript"></script>
   	<script src="lib/sweet-alert.min.js"></script>
<link rel="stylesheet" type="text/css" href="lib/sweet-alert.css">
</head>
<body>
	<script>
		$(document).ready(function(){
			mensaje_w('Error','Usuario o Contraseña incorrecta');
		});
		function mensaje_s(titulo,texto) {
			sweetAlert({
			  title: titulo,
			  text: texto,
			  type: 'success',
			  confirmButtonColor: "#64FE2E",
			  confirmButtonText: "Aceptar",
			  closeOnConfirm: false,
			  html: false
			}, function(){
				location.href="../index.php";
			});
		};
		function mensaje_w(titulo,texto) {
			sweetAlert({
			  title: titulo,
			  text: texto,
			  type: 'warning',
			  confirmButtonColor: "#DD6B55",
			  confirmButtonText: "Aceptar",
			  closeOnConfirm: false,
			  html: false
			}, function(){
				location.href="index.php";
			});
		};
		function mensaje_b(titulo,texto) {
			sweetAlert({
			  title: titulo,
			  text: texto,
			  type: 'warning',
			  confirmButtonColor: "#DD6B55",
			  confirmButtonText: "Aceptar",
			  closeOnConfirm: false,
			  html: false
			}, function(){
				window.history.back();
			});
		};
	</script>
</body>
</html>