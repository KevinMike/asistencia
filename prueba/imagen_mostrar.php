<?php
########## imagen_mostrar.php ##########
# debe recibir el id de la imagen a mostrar
# http://www.lawebdelprogramador.com

# Conectamos con MySQL
$mysqli=new mysqli("127.0.0.1:3306","root","","control_asistencia");
if (mysqli_connect_errno()) {
    die("Error al conectar: ".mysqli_connect_error());
}

# Buscamos la imagen a mostrar
$result=$mysqli->query("SELECT * FROM personal WHERE dni='71025849'");
$row=$result->fetch_array(MYSQLI_ASSOC);

# Mostramos la imagen
header("Content-type:".$row["tipo"]);
echo $row["foto"];
?>