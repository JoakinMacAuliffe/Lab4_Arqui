## ============================================================================
## Archivo de restricciones (XDC) - Laboratorio N.º 04: Temporizador y Contador
## Placa: Digilent Nexys 4 DDR (FPGA Artix-7 XC7A100TCSG324-1)
## ============================================================================

## 1. Reloj del sistema (100 MHz)
set_property -dict { PACKAGE_PIN E3    IOSTANDARD LVCMOS33 } [get_ports { CLK }];
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports { CLK }];

## 2. Pulsadores (Botones de control)
## BTND: Reset general
set_property -dict { PACKAGE_PIN P18   IOSTANDARD LVCMOS33 } [get_ports { RESET }];
## BTNC: Inicio y pausa del temporizador
set_property -dict { PACKAGE_PIN N17   IOSTANDARD LVCMOS33 } [get_ports { START_PAUSE }];
## BTNU: Reset del tiempo
set_property -dict { PACKAGE_PIN M18   IOSTANDARD LVCMOS33 } [get_ports { RESET_TIEMPO }];
## BTNR: Incremento de evento
set_property -dict { PACKAGE_PIN M17   IOSTANDARD LVCMOS33 } [get_ports { EVENTO }];
## BTNL: Reset de eventos
set_property -dict { PACKAGE_PIN P17   IOSTANDARD LVCMOS33 } [get_ports { RESET_EVENTO }];

## 3. LEDs indicadores
## LED0: Temporizador activo (RUNNING)
set_property -dict { PACKAGE_PIN H17   IOSTANDARD LVCMOS33 } [get_ports { RUNNING }];
## LED1: Alarma de tiempo agotado (ALARMA)
set_property -dict { PACKAGE_PIN K15   IOSTANDARD LVCMOS33 } [get_ports { ALARMA }];
## LED2: Indicador de detección de evento (LED_EVENTO)
set_property -dict { PACKAGE_PIN J13   IOSTANDARD LVCMOS33 } [get_ports { LED_EVENTO }];

## 4. Displays de Siete Segmentos - Segmentos (Activos en bajo: CA..CG -> SEG[0]..SEG[6])
set_property -dict { PACKAGE_PIN T10   IOSTANDARD LVCMOS33 } [get_ports { SEG[0] }]; # CA
set_property -dict { PACKAGE_PIN R10   IOSTANDARD LVCMOS33 } [get_ports { SEG[1] }]; # CB
set_property -dict { PACKAGE_PIN K16   IOSTANDARD LVCMOS33 } [get_ports { SEG[2] }]; # CC
set_property -dict { PACKAGE_PIN K13   IOSTANDARD LVCMOS33 } [get_ports { SEG[3] }]; # CD
set_property -dict { PACKAGE_PIN P15   IOSTANDARD LVCMOS33 } [get_ports { SEG[4] }]; # CE
set_property -dict { PACKAGE_PIN T11   IOSTANDARD LVCMOS33 } [get_ports { SEG[5] }]; # CF
set_property -dict { PACKAGE_PIN L18   IOSTANDARD LVCMOS33 } [get_ports { SEG[6] }]; # CG

## 5. Displays de Siete Segmentos - Ánodos (Activos en bajo: AN[0]..AN[7])
## AN[0] y AN[1]: Eventos (EE) | AN[2] y AN[3]: Tiempo (TT) | AN[4..7]: Apagados
set_property -dict { PACKAGE_PIN J17   IOSTANDARD LVCMOS33 } [get_ports { AN[0] }];
set_property -dict { PACKAGE_PIN J18   IOSTANDARD LVCMOS33 } [get_ports { AN[1] }];
set_property -dict { PACKAGE_PIN T9    IOSTANDARD LVCMOS33 } [get_ports { AN[2] }];
set_property -dict { PACKAGE_PIN J14   IOSTANDARD LVCMOS33 } [get_ports { AN[3] }];
set_property -dict { PACKAGE_PIN P14   IOSTANDARD LVCMOS33 } [get_ports { AN[4] }];
set_property -dict { PACKAGE_PIN T14   IOSTANDARD LVCMOS33 } [get_ports { AN[5] }];
set_property -dict { PACKAGE_PIN K2    IOSTANDARD LVCMOS33 } [get_ports { AN[6] }];
set_property -dict { PACKAGE_PIN U13   IOSTANDARD LVCMOS33 } [get_ports { AN[7] }];

## Configuración adicional de voltaje para banco 0
set_property CFGBVS VCCO [current_design];
set_property CONFIG_VOLTAGE 3.3 [current_design];

