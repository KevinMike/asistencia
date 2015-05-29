<!DOCTYPE html>
<html lang="eS">
<head>
	<meta charset="UTF-8">
	<title>Exito</title>
	<link href="../css/normalize.css" rel="stylesheet">
   	<link href="../css/bootstrap.min.css" rel="stylesheet">
   	<script src="../js/jquery-2.1.3.js"type="text/javascript"></script>
   	<script src="../lib/sweet-alert.min.js"></script>
	<link rel="stylesheet" type="text/css" href="../lib/sweet-alert.css">
</head>
<body>
<?php
	echo '<script language="javascript">
				sweetAlert({
				  title: "REGISTRO EXITOSO",
				  text: "Tenga un buen día",
				  type: "success",
				  confirmButtonColor: "#64FE2E",
				  confirmButtonText: "Aceptar",
				  closeOnConfirm: false,
				  html: false,
				  timer: 3500
				}, function(){
					window.location.href = "../index.php";
				});
			setTimeout(function(){
				window.location.href = "../index.php";			    
			}, 3000);
		</script>';
?>