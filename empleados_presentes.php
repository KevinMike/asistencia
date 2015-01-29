<?php
	include("scripts/conexion.php");
	//Imprimir los valores de la tabla empleados
	$resultado = mysql_query('CALL SP_Empleados_Presentes()',$enlace);
	if(!$resultado)
	{
		die('No se pudo realizar la consulta : '.mysql_error());
	}
	$opciones2 = "";
	$empleados = "";
	while ($fila = mysql_fetch_array($resultado)) 
	{
		$opciones2 .= '<tr><td>'.$fila['dni'].'</td><td>';
		$opciones2 .= $fila['hora_llegada'].'</td></tr>';
		$empleados .= "<div class='grilla'><figure><img src='";
		if ($fila['tipo'] == '')  
		{
			$empleados .= "img/sin_avatar.jpg";	
		}
		else
		{
			$empleados .= "scripts/visualizar_imagen.php?dni=".$fila['dni'];
		}
		$empleados .= "' ></figure><div class='datos'><h1>".$fila['nombre']."</h1><p>DNI : ".$fila['dni']."</p><P>Area : ".$fila['area']."</P><p>Cargo : ".$fila['cargo']."</p><p>Hora de Llegada : ".$fila['hora_llegada']."</p>";
		if ($fila['cumple'] == 1) {
			$empleados .= "<h2>¡Feliz Cumpleaños...!</h2>";
		}
		$empleados .= "</div></div>";
	}
	mysql_close();
?>
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<title>Empleados Presentes</title>
	<link href="css/bootstrap.min.css" rel="stylesheet">
	<link href="css/starter-template.css" rel="stylesheet">
	<link rel="stylesheet" href="css/empleados_presentes.css">
</head>
<body>
	<h2>Empleados Presentes</h2>
	<!--<table class="table table-striped">
		<tr >
			<th>DNI</th>
			<th>Hora de llegada</th>
		</tr>
			<?php //echo $opciones2; ?>
	</table>-->
	<div class="contenedor">
		
		<!--<div class='grilla'>
			<figure>
				<img src='img/descarga.jpg'>
			</figure>
			<div class='datos'>
				<h1>Nombre</h1>
				<p>DNI : </p>
				<P>Area : </P>
				<p>Cargo : </p>
				<p>Hora de Legada : </p>
				<h2>¡Feliz Cumpleaños...!</h2>
			</div>
		</div>
		-->
		<?php  echo $empleados; ?>
	</div>
</body>
</html>