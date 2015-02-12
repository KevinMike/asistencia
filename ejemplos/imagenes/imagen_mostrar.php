<?php
########## imagen_mostrar.php ##########
# debe recibir el id de la imagen a mostrar
# http://www.lawebdelprogramador.com

# Conectamos con MySQL
$mysqli=new mysqli("127.0.0.1:3306","root","","imagen");
if (mysqli_connect_errno()) {
    die("Error al conectar: ".mysqli_connect_error());
}

# Buscamos la imagen a mostrar
$result=$mysqli->query("SELECT * FROM `imagephp` WHERE id=".$_GET["id"]);
$row=$result->fetch_array(MYSQLI_ASSOC);

# Mostramos la imagen
header("Content-type:".$row["tipo"]);
echo $row["imagen"];
?>