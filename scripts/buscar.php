<?php
      
      $dni = $_POST['buscardni'];
       
      if(!empty($dni)) {
            buscar($dni);
      }
      /*function buscar($b) {
            $con = mysql_connect('localhost','root', 'root');
            mysql_select_db('base_de_datos', $con);
       
            $sql = mysql_query("SELECT * FROM anuncios WHERE nombre LIKE '%".$b."%'",$con);
             
            $contar = mysql_num_rows($sql);
             
            if($contar == 0){
                  echo "No se han encontrado resultados para '<b>".$b."</b>'.";
            }else{
                  while($row=mysql_fetch_array($sql)){
                        $nombre = $row['nombre'];
                        $id = $row['id'];
                         
                        echo $id." - ".$nombre."<br /><br />";    
                  }
            }
      }*/
      function buscar($dni)
      {
            include('conexion.php');
            $resultado = mysql_query("select * from V_empleados where dni like'{$dni}%' ",$enlace);
            if(!$resultado)
            {
                  die('No se pudo realizar la consulta : '.mysql_error());
            }
            $opciones2 = "<tr><th>Foto</th><th>DNI</th><th>Nombres</th><th>Apellidos</th><th>Fecha de Nacimiento</th><th>Sexo</th><th>Area</th><th>Cargo</th><th>Horario</th><th>Dias Laborables</th><th>Eliminar Registro</th><th>Actualizar datos</th></tr>";
            $contar = mysql_num_rows($resultado);
            if($contar == 0)
            {
                  echo "No se han encontrado resultados para '<b>".$dni."</b>'.";
            }
            else
            {
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
                        $opciones2 .= "<a href='empleados.php?dni={$fila['dni']}'>Editar</a></td><td>";
                        $opciones2 .= "<a href='scripts/eliminar_persona.php?dni={$fila['dni']}'>Eliminar</a></td></tr>";
                  }
                  mysql_close();
                  echo $opciones2;           
            }
      }
?>