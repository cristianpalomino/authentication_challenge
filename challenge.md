
1
🔥 Sapo I: Reto de Programación Flutter + Firebase
-  -  Autenticación - -
Objetivo
Desarrollar una app sencilla en Flutter con verificación de email mediante código (OTP)
usando Firebase Authentication y una Cloud Function personalizada para enviar el
código por correo.

🎯 Requisitos
Crea una pequeña app con el siguiente flujo:
1. Pantalla de Inicio
●  Un único botón: Comenzar
●  Al pulsarlo, debe navegar a la Pantalla de Verificación de Email
2. Pantalla de Verificación de Email
●  Mostrar:
○  Un campo de texto para ingresar un correo electrónico
○  Un botón: Enviar código de verificación
●  Al pulsar:
○  Llama a una Cloud Function desplegada en Firebase que:
■  Genera un código aleatorio de 6 dígitos
■  Envía ese código al correo ingresado usando SendGrid.
■  Guarda el código temporalmente junto con el correo en una colección
de Firestore.
○  Sustituye el campo y botón anteriores por:
■  Un nuevo campo de texto: Introduce el código de
verificación
■  Un botón: Verificar email
●  Al verificar correctamente:
○  Almacena el correo, uid y una bandera llamada verifiedEmail en otra
colección de Firestore.
○  Muestra un mensaje de éxito

🔐 Acceso al Proyecto Firebase
Para poder revisar tu implementación:
●  Invita a comando@technologica.world como Editor de tu proyecto de
Firebase/GCP.

✅ Criterios de Evaluación
Evaluaremos tu entrega en base a:
●  Funcionamiento completo del flujo de verificación
●  Claridad y estructura del código
●  UX/UI sencilla y comprensible, incluyendo instrucciones adecuadas y manejo
amigable de errores.


⏱Tiempo de entrega
●  Aprox. 3 días
