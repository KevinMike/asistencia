<html> 
<head> 
   <meta charset="UTF-8">
   <title>Asistencia</title>
   	<link href="css/index.css" rel="stylesheet">
   	<link href="css/bootstrap.min.css" rel="stylesheet">
	<link href="css/starter-template.css" rel="stylesheet">
	<link href="./css/bootstrap.css" rel="stylesheet">
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
	<header><img src="img/inei.png" height="50px" alt=""><h1>SISTEMA DE CONTROL DE ASISTENCIA</h1></header>
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
						<input type="text" name="dni" required placeholder="DNI" maxlength="8">
					</div>
					<div class="controls">
						<!--<label for="password">Contraseña : </label>-->
						<input type="password" name="password" required placeholder="Contraseña"maxlength="15">
					</div>
					<br>
					<input type="submit" class="btn btn-success">
					<input class="btn btn-primary" type="reset">
	   			</div>
	   		</form>
		<!--
		   	<div class="container">
		        <h3>Formulario</h3>
		        <form action="./formulario" method="get" >
		            <div class="control-group">
		                <h4>Rellene sus datos</h4>
		                <div class="control-group">
		                    <div class="controls">
		                        <input type="text" name="usuario" placeholder="Usuario">
		                    </div>
		                </div>
		                <div class="controls">
		                    <input type="password" name="passw" placeholder="Contrase&ntilde;a" />
		                    <label class="checkbox">
		                        <input type="checkbox" name="recordar" value="recordar">Recordarme
		                    </label>
		                </div>
		            </div>
		            <input type="submit" class="btn btn-primary" value="Enviar"/>
		        </form>
		    </div>
		-->
		</div>
	   <iframe src="empleados_presentes.php" frameborder="0" width="100%"></iframe>
   </div>
</body>
</html>
