# Laboratorio 4: Temporizador regresivo y contador de eventos en FPGA

CIT2109 Arquitectura y Organización de Computadores, Universidad Diego Portales.
Plataforma: Nexys 4 DDR (Artix-7 XC7A100T). Lenguaje: VHDL. Herramienta: Vivado 2023.1.

**Integrantes:** Benjamín Oyarzún, Lucas Herrada, Joakin Mac-Auliffe.

## Descripción

Sistema que muestra `TT EE` en cuatro displays de siete segmentos:

- `TT`: temporizador regresivo de 00 a 99 s, con inicio/pausa, reinicio y alarma al llegar a 00.
- `EE`: contador de eventos de 00 a 99, con saturación y reinicio independiente.
- Actividad adicional: alarma intermitente (LED1 a 2 Hz).

Los pulsadores pasan por sincronizador y detector de flanco, y las bases de tiempo se generan con señales de habilitación sobre el único reloj de 100 MHz.

## Estructura del repositorio

| Carpeta | Contenido |
|---|---|
| `src/` | Módulos VHDL: `lab04_top`, `generador_ticks`, `detector_flanco`, `temporizador_bcd`, `contador_eventos`, `bcd7seg`, `mux_display`, `alarma_intermitente` |
| `sim/` | Banco de pruebas autoverificable `tb_lab04.vhd` |
| `constr/` | Restricciones de pines y reloj `lab04.xdc` |
| `LAB04_TEMPORIZADOR_EVENTOS/` | Proyecto de Vivado (`.xpr`); abrir con Vivado 2023.1 |
| `bitstream/` | `lab04_top.bit` listo para programar la placa |
| `informe/` | Informe en LaTeX (`informe4.tex`), su PDF y las imágenes (`img/`) |
| `docs/` | Guía del laboratorio (PDF y Markdown) |

Los archivos de `src/`, `sim/` y `constr/` son las mismas fuentes que usa el proyecto de Vivado.

## Cómo usarlo

**Vivado:** abrir `LAB04_TEMPORIZADOR_EVENTOS/LAB04_TEMPORIZADOR_EVENTOS.xpr`. Simulación: *Run Simulation → Run Behavioral Simulation* sobre `tb_lab04`.

**Placa:** programar `bitstream/lab04_top.bit` desde *Hardware Manager*.

**Informe:** compilar `informe/informe4.tex` con `pdflatex` o `latexmk` (por ejemplo, con LaTeX Workshop en VS Code).

## Controles en la placa

| Elemento | Función |
|---|---|
| BTNC | Inicio y pausa |
| BTNU | Reinicio del tiempo |
| BTNR | Incrementa eventos |
| BTNL | Reinicio de eventos |
| BTND | Reinicio general |
| LED0 | Temporizador activo |
| LED1 | Alarma (intermitente) |
| LED2 | Evento detectado |

Nota de diseño: cada pulsación de BTNC (inicio/pausa) también se cuenta como evento.

## Video de demostración

https://drive.google.com/file/d/1nHihV9UcWKYV1jOAFT8KAInJGRiwbBy_/view?usp=sharing
