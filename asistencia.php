<html> 
<head> 
   <meta charset="UTF-8">
   <title>Asistencia</title>
   	<link href="css/index.css" rel="stylesheet">
   	<link href="css/bootstrap.min.css" rel="stylesheet">
	<link href="css/starter-template.css" rel="stylesheet">
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
	<form id="form_reloj"name="form_reloj"> 
		<input type="text" id="reloj" name="reloj" onfocus="window.document.form_reloj.reloj.blur()" size="40"> 
	</form>
	<form class="form-inline" role="form" action="scripts/registro_ingreso.php" method="POST">
			<label for="dni">Ingrese su numero de DNI : </label>
			<input type="text" name="dni" required>
			<label for="password">Contraseña : </label>
			<input type="password" name="password" required>
			<input type="submit" class="btn btn-default">
   </form>
   <iframe src="empleados_presentes.php" frameborder="0" width="100%"></iframe>
</body>
</html>
