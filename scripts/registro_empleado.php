<?php
	# Conectamos con MySQL
	$mysqli=new mysqli("127.0.0.1:3306","root","","control_asistencia");
	if (mysqli_connect_errno()) 
	{
	    die("Error al conectar: ".mysqli_connect_error());
	}
	//include('conexion.php');
	$dni = $_POST['DNI'];
	$nombre = $_POST['nombre'];
	$apellido = $_POST['apellido'];
	$fecha_nacimiento = $_POST['fecha_nacimiento'];
	$sexo = $_POST['sexo'];
	$cod_area = $_POST['area'];
	$cargo = $_POST['cargo'];
	$password = $_POST['password'];
	$lunes = $_POST['Monday'];
	$martes = $_POST['Tuesday'];
	$miercoles = $_POST['Wednesday'];
	$jueves = $_POST['Thursday'];
	$viernes = $_POST['Friday'];
	$sabado = $_POST['Saturday'];
	$domingo = $_POST['Sunday'];
	$cod_horario = $_POST['horario'];
// Los posible valores que puedes obtener de la imagen son:
//echo "<BR>".$_FILES["userfile"]["name"];      //nombre del archivo
//echo "<BR>".$_FILES["userfile"]["type"];      //tipo
//echo "<BR>".$_FILES["userfile"]["tmp_name"];  //nombre del archivo de la imagen temporal
//echo "<BR>".$_FILES["userfile"]["size"];      //tamaño

# Comprovamos que se haya subido un fichero
	if (is_uploaded_file($_FILES["userfile"]["tmp_name"]))
	{
	    # verificamos el formato de la imagen
	    if ($_FILES["userfile"]["type"]=="image/jpeg" || $_FILES["userfile"]["type"]=="image/pjpeg" || $_FILES["userfile"]["type"]=="image/gif" || $_FILES["userfile"]["type"]=="image/bmp" || $_FILES["userfile"]["type"]=="image/png")
	    {
	        # Cogemos la anchura y altura de la imagen
	        $info=getimagesize($_FILES["userfile"]["tmp_name"]);
	        //echo "<BR>".$info[0]; //anchura
	        //echo "<BR>".$info[1]; //altura
	        //echo "<BR>".$info[2]; //1-GIF, 2-JPG, 3-PNG
	        //echo "<BR>".$info[3]; //cadena de texto para el tag <img

	        # Escapa caracteres especiales
	        $imagenEscapes=$mysqli->real_escape_string(file_get_contents($_FILES["userfile"]["tmp_name"]));

	        # Agregamos la imagen a la base de datos
	        //$consulta = "INSERT INTO personal(dni,nombre,apellido,fecha_nacimiento,sexo,area_cod_area,cargo,password,tipo,foto) VALUES('{$dni}','{$nombre}','{$apellido}','{$fecha_nacimiento}',b'{$sexo}','$cod_area','$cargo','{$password}','{$_FILES["userfile"]["type"]}','{$imagenEscapes}')";
	        $consulta = "call SP_Ingresar_Empleado(
'{$dni}','{$nombre}','{$apellido}','{$fecha_nacimiento}',b'{$sexo}','{$cod_area}','{$cargo}','{$password}','{$_FILES["userfile"]["type"]}','{$imagenEscapes}','{$cod_horario}',b'{$domingo}',b'{$lunes}',b'{$martes}',b'{$miercoles}',b'{$jueves}',b'{$viernes}',b'{$sabado}');";
	        //$sql="INSERT INTO `imagephp` (anchura,altura,tipo,imagen) VALUES (".$info[0].",".$info[1].",'".$_FILES["userfile"]["type"]."','".$imagenEscapes."')";
	        $mysqli->query($consulta);

	        # Cogemos el identificador con que se ha guardado
	        //$id=$mysqli->insert_id;

	        # Mostramos la imagen agregada
	        //echo "<div class='mensaje'>Imagen agregada con el id ".$id."</div>";
			header('Location:../empleados.php');
	    }else{
	        echo "<div class='error'>Error: El formato de archivo tiene que ser JPG, GIF, BMP o PNG.</div>";
	    }
	}
	else
	{
		 $consulta = "call SP_Ingresar_Empleado(
'{$dni}','{$nombre}','{$apellido}','{$fecha_nacimiento}',b'{$sexo}','{$cod_area}','{$cargo}','{$password}','',null,'{$cod_horario}',b'{$domingo}',b'{$lunes}',b'{$martes}',b'{$miercoles}',b'{$jueves}',b'{$viernes}',b'{$sabado}');";
		//$resultado = mysql_query($query,$enlace);
		//echo $consulta;
		$mysqli->query($consulta);
		/*if (!$resultado) {
			die("No de pudo hacer el registro : ".mysql_error());
		}*/
		header('Location:../empleados.php');
	}
?>
