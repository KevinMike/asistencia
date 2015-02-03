<?php
	include("scripts/conexion.php");
		//Imprimir los valores de la tabla empleados
	$resultado = mysql_query('select * from V_empleados',$enlace);
	if(!$resultado)
	{
		die('No se pudo realizar la consulta : '.mysql_error());
	}
	$opciones2 = "";
	while ($fila = mysql_fetch_array($resultado)) 
	{
		$opciones2 .= "<tr><td><img src='";
		if ($fila['tipo'] == '')  
		{
			$opciones2 .= "img/sin_avatar.jpg";	
		}
		else
		{
			$opciones2 .= 'scripts/visualizar_imagen.php?dni='.$fila['dni'];
		}
		$opciones2 .= "' width = 80px ><td>".$fila['dni']."</td><td>";
		$opciones2 .= $fila['nombre']."</td><td>";
		$opciones2 .= $fila['apellido']."</td><td>";
		$opciones2 .= $fila['fecha_nacimiento']."</td><td>";
		$opciones2 .= $fila['sexo']."</td><td>";
		$opciones2 .= $fila['area']."</td><td>";
		$opciones2 .= $fila['cargo']."</td><td>";
		$opciones2 .= $fila['Horario']."</td><td>";
		$opciones2 .= $fila['dias']."</td><td>";
		$opciones2 .= "<a href='#.php?dni={$fila['dni']}'>Editar</a></td><td>";
		$opciones2 .= "<a href='scripts/eliminar_persona.php?dni={$fila['dni']}'>Eliminar</a></td></tr>";
	}
	mysql_close();
?>
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<title>Document</title>
	<script src="js/jquery-1.11.2.min.js"type="text/javascript"></script>
	<link href="css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
		<script type="text/javascript">
		$(document).ready(function(){
	                                
	        var consulta;
	                                                                          
	         //hacemos focus al campo de búsqueda
	        $("#busqueda").focus();
	                                                                                                    
	        //comprobamos si se pulsa una tecla
	        $("#busqueda").keyup(function(e){
                  
	              //obtenemos el texto introducido en el campo de búsqueda
	              consulta = $("#busqueda").val();
	                                                                           
	              //hace la búsqueda
	                                                                                  
	              $.ajax({
	                    type: "POST",
	                    url: "scripts/buscar.php",
	                    data: "buscardni="+consulta,
	                    dataType: "html",
	                    beforeSend: function(){
	                          //imagen de carga
	                          $("#resultado").html("<p align='center'><img src='ajax-loader.gif' /></p>");
	                    },
	                    error: function(){
	                          alert("error petición ajax");
	                    },
	                    success: function(data){                                                    
	                          $("#resultado").empty();
	                          $("#resultado").append(data);
	                                                             
	                    }
	              });
	                                                                                  
	        });
	                                                                   
	});
	</script>
	<h2>Buscar Empleados por DNI</h2>
	<label for="buscadni">Ingrese el DNI : </label>
	<input type="text" id="busqueda" name="buscadni"/>
    <table class="table table-striped" id="resultado">

    </table>

	<h2>Personal Registrados</h2>
	<table class="table table-striped">
		<tr >
			<th>Foto</th>
			<th>DNI</th>
			<th>Nombres</th>
			<th>Apellidos</th>
			<th>Fecha de Nacimiento</th>
			<th>Sexo</th>
			<th>Area</th>
			<th>Cargo</th>
			<th>Horario</th>
			<th>Dias Laborables</th>
			<th>Eliminar Registro</th>
			<th>Actualizar datos</th>
		</tr>
			<?php echo $opciones2; ?>
	</table>
</body>
</html>