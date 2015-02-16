	
<?php
	require('scripts/fpdf.php');


	class PDF extends FPDF
	{
		// Cabecera de página
		function Header()
		{
		    
		    // Logo
		    $this->Image('img/inei.png',10,8,33);
		    // Arial bold 15
		    $this->SetFont('Arial','B',15);
		    // Movernos a la derecha
		    $this->Cell(80);
		    // Título
		    $this->Cell(30,10,'Control de Asistencia',0,1,'C');
		    //Subtitulo
		   /* $this->Ln();
		    $this->Cell(80);
		    $this->SetFont('Arial','',12);
		    $this->Cell(30,10,'Informe de asistencia desde '.$desde.' hasta '.$hasta,0,1,'C');*/
		    // Salto de línea
		    $this->Ln(20);
		}

		// Tabla simple
		function BasicTable($header, $data)
		{
		    // Cabecera
		    foreach($header as $col)
		        $this->Cell(40,7,$col,1);
		    $this->Ln();

		    while ($linea=sqlsrv_fetch_array($data,SQLSRV_FETCH_NUMERIC)) {
		    	foreach ($linea as $row) {     		
			    	$this->Cell(40,6,$row,1);
		    	}
				$this->Ln();
		    }
		}


		// Una tabla más completa
		function ImprovedTable($header, $w, $data)
		{
		     //Datos Personales
		     $this->Cell(0,6,"DATOS PERSONALES",0,'C');
		     $this->Ln();
		     $this->Cell(20,6,"Nombre : ",1,'LR');
		     $this->Cell(80,6,"Kevin Herrera",1,'LR');
		     $this->Cell(20,6,"Area : ",1,'LR');
		     $this->Cell(67,6,"ENEI",1,'LR');
		     $this->Ln();
		     $this->Cell(20,6,"Horario : ",1,'LR');
		     $this->Cell(167,6,"ENEI",1,'LR');
		     $this->Ln();
		     $this->Cell(27,6,"Dias Laborables : ",1,'LR');
		     $this->Cell(73,6,"L - M - MI - J - V - S - D",1,'LR');
		     $this->Cell(20,6,"Cargo : ",1,'LR');
		     $this->Cell(67,6,"Practicante",1,'LR');
			 $this->Ln();
		     $this->Ln();
		     $this->Cell(0,6,"ASISTENCIA",0,'C');
		     $this->Ln();
		     
		    // Anchuras de las columnas
		    
		    // Cabeceras
		    for($i=0;$i<count($header);$i++)
		        $this->Cell($w[$i],7,$header[$i],1,0,'C');
		    $this->Ln();
		    // Datos
		    while($linea=mysql_fetch_array($data))
		    {
		    	 
			        $this->Cell($w[0],6,$linea[0],'LR');
			        $this->Cell($w[1],6,$linea[1],'LR');
			        $this->Cell($w[2],6,$linea[2],'LR',0,'R');
			        $this->Cell($w[3],6,$linea[3],'LR',0,'R');
			        $this->Cell($w[4],6,$linea[4],'LR');
			        $this->Cell($w[5],6,$linea[5],'LR');
			        //$this->Cell($w[6],6,$linea[6],'LR');
	 
			        $this->Ln();
			     
		    }
			    
		    // Línea de cierre
		    $this->Cell(array_sum($w),0,'','T');
		}

		// Tabla coloreada
		function FancyTable($header,$w, $data,$data2,$desde,$hasta)
		{
		     //Datos Personales
			 $this->SetFont('Arial','B',12);
		     $this->Cell(0,8,"DATOS PERSONALES",0,'C');
		     $this->SetFont('Arial','',9);
		     $this->Ln();
		     $this->Cell(27,5,"Nombre : ",0,'LR');
		     $this->Cell(73,5,$data2['apellido'].", ".$data2['nombre'],0,'LR');
		     $this->Cell(20,5,"Area : ",0,'LR');
		     $this->Cell(67,5,$data2['area'],0,'LR');
		     $this->Ln();
		     $this->Cell(27,5,"Dias Laborables : ",0,'LR');
		     $this->Cell(73,5,$data2['dias'],0,'LR');
		     $this->Cell(20,5,"Cargo : ",0,'LR');
		     $this->Cell(67,5,$data2['cargo'],0,'LR');
		     $this->Ln();
		     $this->Cell(27,5,"Horario : ",0,'LR');
		     $this->Cell(160,5,$data2['Horario'],0,'LR');
		     $this->Ln(10);
		     $this->SetFont('Arial','B',12);
		     $this->Cell(0,8,"INFORME DE ASISTENCIA DESDE EL ".$desde." HASTA EL ".$hasta,0,'C');
		     $this->SetFont('Arial','',9);
		     $this->Ln();

		    // Colores, ancho de línea y fuente en negrita
		    $this->SetFillColor(128,128,128);
		    $this->SetTextColor(255);
		    $this->SetDrawColor(192,192,192);
		    $this->SetLineWidth(.1);


		    // Cabecera
		     
		    for($i=0;$i<count($header);$i++)
		        $this->Cell($w[$i],7,$header[$i],1,0,'C',true);
		    $this->Ln();
		    // Restauración de colores y fuentes
		    $this->SetFillColor(224,235,255);
		    $this->SetTextColor(0);
		    $this->SetFont('');
		    // Datos
		    $fill = false;
	 

		    while($linea=mysql_fetch_array($data))
		    {
		    	 for ($i=0; $i < count($header) ; $i++) { 
			        $this->Cell($w[$i],6,$linea[$i],'LR',0,'C',$fill);
			        		    	 
			    }
			    $this->Ln();
		    }
			    
		    // Línea de cierre
		    $this->Cell(array_sum($w),0,'','T');
		}

		// Pie de página
		function Footer()
		{
		    // Posición: a 1,5 cm del final
		    $this->SetY(-15);
		    // Arial italic 8
		    $this->SetFont('Arial','I',8);
		    // Número de página
		    $this->Cell(0,10,'Page '.$this->PageNo().'/{nb}',0,0,'C');
		}
	}

	include("scripts/conexion.php");
	//recibiendo Variables
	$desde = $_REQUEST['desde'];
	$hasta = $_REQUEST['hasta'];
	$dni = $_REQUEST['dni'];
	$query = "select * from V_empleados where dni = '{$dni}'";
	$datos = mysql_query($query);
	$personales = mysql_fetch_array($datos);

	$query = "call SP_Ver_Reporte('{$dni}','{$desde}','{$hasta}')";
	$resultado = mysql_query($query);

	$pdf = new PDF();
	// Títulos de las columnas
	$header = array('Fecha', 'Hora de Llegada', 'Salida para Almorzar', 'Regreso de Almorzar','Hora de Salida','Permiso');
	$w = array(20, 25, 32, 35,25,50);
	$desde1 = date_create($desde);
	$hasta1 = date_create($hasta);
	$pdf->AliasNbPages();
	$pdf->SetFont('Arial','',9);
	$pdf->AddPage();
	$pdf->FancyTable($header, $w, $resultado,$personales,date_format($desde1,'d/m/Y'),date_format($hasta1,'d/m/Y'));
	//$pdf->ImprovedTable($header, $w, $resultado);
	$pdf->Output();
?>