<?php
	session_start();
	if (!empty($_SESSION['login'])) {
		if ($_SESSION['login'] == true) {
		 	$next = "window.location.href='panel.php'";
		 } 
		 else
		 {
		 	$next = "toggle_element('.formulario',1000)";
		 }
	}
	else
	{
		$next = "toggle_element('.formulario',1000)";
	}
?>
<html> 
<head> 
   <meta charset="UTF-8">
   <title>Asistencia</title>
	<link href="css/normalize.css" rel="stylesheet">
   	<link href="css/bootstrap.min.css" rel="stylesheet">
   	<link href="css/index.css" rel="stylesheet">
   	<script src="js/jquery-2.1.3.js"type="text/javascript"></script>
	<script language="JavaScript"> 
		function mueveReloj(){ 
		   	momentoActual = new Date() 
		   	hora = momentoActual.getHours() 
		   	minuto = momentoActual.getMinutes() 
		   	segundo = momentoActual.getSeconds() 
		   	str_segundo = new String (segundo) 
		   	if (str_segundo.length == 1) 
		      	segundo = "0" + segundo 
		   	str_minuto = new String (minuto) 
		   	if (str_minuto.length == 1) 
		      	minuto = "0" + minuto 
		   	str_hora = new String (hora) 
		   	if (str_hora.length == 1) 
		      	hora = "0" + hora 
		   	horaImprimible = hora + " : " + minuto + " : " + segundo 
		   	document.form_reloj.reloj.value = horaImprimible 
		   	setTimeout("mueveReloj()",1000) 
		} 
	</script> 
</head> 

<body onload="mueveReloj()" > 
	<header>
		<img class="logo" src="img/inei.png" height="50px" alt="">
		<h1>CONTROL DE ASISTENCIA</h1>
		<nav><a onclick="<?php echo $next; ?>" name="motrarlogin" ><img src="img/icon.png" alt="">Panel de Administración</a></nav>
		<script type="text/javascript">
			$(document).ready(function(){
				$('.formulario').toggle();
				$("#dni").focus();
			});
			function toggle_element(element,speed){
				$(element).toggle(speed);
			}
		</script>
	</header>
	<div class="formulario">
		<form  role="form" name="login" id="login" action="scripts/login.php" method="POST">
			<div class="form-group">
				<label for="user">Usuario : </label>
				<input class="form-control" type="text" name="user" placeholder="Usuario"  maxlength="15">
			</div>
			<div class="form-group">
				<label for="password">Contraseña : </label>
				<input class="form-control" type="password" name="password" placeholder="Contraseña"  maxlength="15">
			</div>
			<input type="submit" class="btn btn-info" value="Login">
			<input type="reset" class="btn btn-warning" value="Limpiar">
		</form>
	</div>
	<div class="contenedor">
		<div class="datos">
			<form id="form_reloj"name="form_reloj"> 
				<input type="text" id="reloj" name="reloj" onfocus="window.document.form_reloj.reloj.blur()" size="40"> 
			</form>
			<h3>Formulario de Ingresos y Salidas</h3>
			<form action="scripts/registro_ingreso.php" method="POST">
				<div class="control-group">
					<h4>Rellene sus datos</h4>
					<div class="controls">
						<!--<label for="dni">Ingrese su numero de DNI : </label>-->
						<input type="text" id ="dni" name="dni" required placeholder="DNI" maxlength="8">
					</div>
					<div class="controls">
						<!--<label for="password">Contraseña : </label>-->
						<input type="password" id = "password" name="password" required placeholder="Contraseña"maxlength="15">
					</div>
					<br>
					<input type="submit" class="btn btn-success" value="Registrar">
					<input class="btn btn-primary" type="reset" value="Limpiar">
	   			</div>
	   		</form>
		</div>
	   <iframe src="empleados_presentes.php" frameborder="0" width="100%"></iframe>
   </div>
</body>
</html>
