% ==========================================
% SISTEMA EXPERTO DE DIAGNÓSTICO DE PC
% ==========================================

% Declaración de hechos dinámicos para almacenar respuestas del usuario
:- dynamic respuesta/2.

% Inicialización
main :-
    writeln('================================================='),
    writeln('   SISTEMA DE ASESORIA: ACTUALIZAR O COMPRAR'),
    writeln('================================================='),
    writeln('Este sistema analizara tu equipo actual para'),
    writeln('darte la mejor recomendacion tecnica.'),
    writeln(''),
    borrar_datos,
    realizar_preguntas,
    realizar_diagnostico.

% Limpiar memoria antes de empezar
borrar_datos :-
    retractall(respuesta(_,_)).

% ==========================================
% MÓDULO DE PREGUNTAS
% ==========================================

realizar_preguntas :-
    pregunta_uso,
    pregunta_tipo_equipo,
    pregunta_lentitud,
    pregunta_mantenimiento,
    pregunta_procesador,
    pregunta_ram_cantidad,
    pregunta_ram_soldada,
    pregunta_ram_slots,
    pregunta_almacenamiento_gb,
    pregunta_tipo_disco,
    pregunta_disco_soldado,
    pregunta_sistema_operativo.

% 1. Uso
pregunta_uso :-
    writeln('1. ¿Que tipo de uso le das a tu laptop?'),
    writeln('1. Uso ligero (Navegacion, YouTube)'),
    writeln('2. Uso medio (Office, muchas pestañas, ediciones simples)'),
    writeln('3. Uso rudo (Renderizado, Programacion, Juegos AAA)'),
    read(R),
    assert(respuesta(uso, R)).

% 2. Tipo de equipo
pregunta_tipo_equipo :-
    writeln('2. ¿Tu computadora es Laptop o Escritorio?'),
    writeln('1. Laptop'),
    writeln('2. Escritorio'),
    read(R),
    assert(respuesta(tipo_equipo, R)).

% 3. Lentitud
pregunta_lentitud :-
    writeln('3. ¿Actualmente, tu equipo es lento para encender?'),
    writeln('1. Si'),
    writeln('2. No'),
    read(R),
    assert(respuesta(es_lento, R)).

% 4. Mantenimiento
pregunta_mantenimiento :-
    writeln('4. ¿Le has dado mantenimiento fisico (limpieza/pasta) recientemente?'),
    writeln('1. Si'),
    writeln('2. No'),
    read(R),
    assert(respuesta(mantenimiento, R)).

% 5. Procesador (Simplificado por grupos para logica)
pregunta_procesador :-
    writeln('5. Selecciona tu procesador de la lista:'),
    writeln('--- GAMA BAJA / ANTIGUOS ---'),
    writeln('1. i3 (Gen 4 o menor)'),
    writeln('2. i5 (Gen 4 o menor)'),
    writeln('3. i7 (Gen 4 o menor)'),
    writeln('--- GAMA MEDIA / MEDIANAMENTE ANTIGUOS ---'),
    writeln('4. i3 (Gen 5-8)'),
    writeln('5. i5 (Gen 5-8)'),
    writeln('6. i7 (Gen 5-8)'),
    writeln('7. Ryzen 3000/4000 Series'),
    writeln('--- GAMA ALTA / MODERNOS ---'),
    writeln('8. i3 (Gen 9+)'),
    writeln('9. i5 (Gen 9+)'),
    writeln('10. i7 (Gen 9+)'),
    writeln('11. Ryzen 5000/6000/7000 Series'),
    read(R),
    clasificar_cpu(R, Nivel),
    assert(respuesta(nivel_cpu, Nivel)).

% Regla auxiliar para clasificar CPU internamente
clasificar_cpu(X, bajo) :- X =< 3.
clasificar_cpu(X, medio) :- X >= 4, X =< 7.
clasificar_cpu(X, alto) :- X >= 8.

% 6. RAM Cantidad
pregunta_ram_cantidad :-
    writeln('6. ¿Cuanta memoria RAM tiene?'),
    writeln('1. 6 GB o menor'),
    writeln('2. 8 GB'),
    writeln('3. 12 GB'),
    writeln('4. 16 GB o mayor'),
    read(R),
    assert(respuesta(cantidad_ram, R)).

% 7. RAM Soldada
pregunta_ram_soldada :-
    respuesta(tipo_equipo, 1), % Solo preguntar si es Laptop
    writeln('7. ¿Tu computadora tiene la RAM soldada?'),
    writeln('1. Si'),
    writeln('2. No'),
    writeln('3. No lo se'),
    read(R),
    assert(respuesta(ram_soldada, R)), !.
pregunta_ram_soldada :- assert(respuesta(ram_soldada, 2)). % Si es escritorio, asumimos no soldada

% 8. RAM Slots Extra
pregunta_ram_slots :-
    writeln('8. ¿Tiene espacio (slot) para conectar otra RAM?'),
    writeln('1. Si'),
    writeln('2. No'),
    read(R),
    assert(respuesta(slots_ram, R)).

% 9. Almacenamiento Cantidad
pregunta_almacenamiento_gb :-
    writeln('9. ¿Cuanto espacio en disco tiene?'),
    writeln('1. 240 GB o menor'),
    writeln('2. 241 - 512 GB'),
    writeln('3. Mayor a 512 GB'),
    read(R),
    assert(respuesta(capacidad_disco, R)).

% 10. Tipo de Disco
pregunta_tipo_disco :-
    writeln('10. ¿Que tipo de disco tienes?'),
    writeln('1. HDD (Disco Mecanico tradicional)'),
    writeln('2. SSD / M.2 / NVMe (Estado Solido)'),
    read(R),
    assert(respuesta(tipo_disco, R)).

% 11. Disco Soldado
pregunta_disco_soldado :-
    respuesta(tipo_equipo, 1),
    writeln('11. ¿El disco viene soldado a la placa (comun en mac o laptops ultra delgadas)?'),
    writeln('1. Si'),
    writeln('2. No'),
    read(R),
    assert(respuesta(disco_soldado, R)), !.
pregunta_disco_soldado :- assert(respuesta(disco_soldado, 2)).

% 12. Sistema Operativo
pregunta_sistema_operativo :-
    writeln('12. ¿Que sistema operativo manejas?'),
    writeln('1. Windows 7/8/XP/Vista (Antiguos)'),
    writeln('2. Windows 10'),
    writeln('3. Windows 11'),
    read(R),
    assert(respuesta(so, R)).

% ==========================================
% MÓDULO DE DIAGNÓSTICO (Lógica Experta)
% ==========================================

realizar_diagnostico :-
    writeln(''),
    writeln('======================================'),
    writeln('       RESULTADO DEL DIAGNOSTICO      '),
    writeln('======================================'),
    % Evaluamos reglas en orden de prioridad
    (   diagnostico_urgente_cambio;
        diagnostico_disco_duro;
        diagnostico_ram_insuficiente;
        diagnostico_mantenimiento;
        diagnostico_buen_estado
    ),
    writeln('======================================').


% CASO 1: Equipo Obsoleto para uso Rudo o Medio
diagnostico_urgente_cambio :-
    respuesta(uso, U), U > 1,            % Uso Medio o Alto
    respuesta(nivel_cpu, bajo),          % CPU Legacy (Gen 4 o menor)
    writeln('>> DICTAMEN: REEMPLAZO DE EQUIPO INMINENTE'),
    writeln('----------------------------------------------------------------'),
    writeln('Analisis Tecnico: La arquitectura del procesador es obsoleta (Legacy)'),
    writeln('y no cuenta con el conjunto de instrucciones necesario para su carga'),
    writeln('de trabajo actual. Invertir en este equipo no es financieramente viable.'),
    writeln(''),
    writeln('--- GESTION DE RESIDUOS Y RESPONSABILIDAD SOCIAL ---'),
    writeln('Aunque el equipo no sirve para su trabajo, aun funciona para tareas basicas.'),
    writeln('ACCION RECOMENDADA: No deseche este equipo en la basura comun.'),
    writeln('1. DONACION: Entreguelo a una escuela o fundacion que necesite equipos ofimaticos.'),
    writeln('2. RECICLAJE: Llevelo a un Centro de Acopio de Electronicos (RAEE) para'),
    writeln('   asegurar que sus componentes no contaminen el medio ambiente.').
    
% CASO 2: Cuello de botella por Disco Mecanico (HDD)
diagnostico_disco_duro :-
    respuesta(tipo_disco, 1),           % Tiene HDD
    respuesta(disco_soldado, 2),        % No esta soldado
    writeln('>> RECOMENDACION: ACTUALIZACION PRIORITARIA (CAMBIAR DISCO)'),
    writeln('Justificacion: Tienes un Disco Mecanico (HDD). Este es el componente'),
    writeln('que mas alenta tu PC. Cambiarlo por un SSD hara que se sienta 10 veces mas rapida.'),
    writeln('Costo aproximado: Bajo-Medio.').

% CASO 3: Falta de RAM (Uso rudo con poca RAM)
diagnostico_ram_insuficiente :-
    respuesta(uso, 3),                  % Uso Rudo
    respuesta(cantidad_ram, C), C =< 2, % 8GB o menos
    respuesta(slots_ram, 1),            % Hay espacio
    writeln('>> RECOMENDACION: ACTUALIZAR MEMORIA RAM'),
    writeln('Justificacion: Para uso rudo (programacion/render), necesitas minimo 16GB.'),
    writeln('Tienes slots disponibles, asi que expandir la memoria es la mejor opcion.').

% CASO 3.1: Falta de RAM pero sin slots (Caso triste)
diagnostico_ram_insuficiente :-
    respuesta(uso, 3),
    respuesta(cantidad_ram, C), C =< 2,
    respuesta(slots_ram, 2),            % NO hay espacio
    writeln('>> RECOMENDACION: COMPRAR EQUIPO NUEVO A MEDIANO PLAZO'),
    writeln('Justificacion: Necesitas mas RAM para tu trabajo, pero tu equipo'),
    writeln('no permite expansion. Llegaras al limite tecnico pronto.').

% CASO 4: Mantenimiento
diagnostico_mantenimiento :-
    respuesta(es_lento, 1),             % Es lenta
    respuesta(mantenimiento, 2),        % No ha tenido mantenimiento
    writeln('>> RECOMENDACION: MANTENIMIENTO PREVENTIVO'),
    writeln('Justificacion: Tu hardware parece decente, pero reportas lentitud y falta'),
    writeln('de mantenimiento. El polvo y la pasta termica seca causan sobrecalentamiento'),
    writeln('y reducen el rendimiento (Thermal Throttling). Limpiala primero.').

% CASO 5: Sistema Operativo Obsoleto
diagnostico_mantenimiento :-
    respuesta(so, 1),                   % Windows viejo
    writeln('>> RECOMENDACION: ACTUALIZAR SOFTWARE'),
    writeln('Justificacion: Usas un sistema operativo antiguo sin soporte de seguridad.'),
    writeln('Si tu hardware lo permite, instala Windows 10 o pasate a Linux Lite.').

% CASO 6: Todo Bien
diagnostico_buen_estado :-
    writeln('>> RECOMENDACION: TU EQUIPO ESTA OPTIMO O NO REQUIERE CAMBIOS URGENTES'),
    writeln('Justificacion: Basado en tus respuestas, tu equipo cumple con las'),
    writeln('necesidades para el tipo de uso que le das. Si sientes lentitud,'),
    writeln('considera formatear el equipo (instalacion limpia de Windows).').

:- initialization(main).
