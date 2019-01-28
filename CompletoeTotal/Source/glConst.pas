(*******************************************************)
(*                                                     *)
(*       Engine Paulovich DirectX                      *)
(*       Win32-DirectX API Unit                        *)
(*                                                     *)
(*       Copyright (c) 2003-2004, Ivan Paulovich       *)
(*                                                     *)
(*       iskatrek@hotmail.com  uin#89160524            *)
(*                                                     *)
(*       Unit: glConst                                 *)
(*                                                     *)
(*******************************************************)

unit glConst;

interface

const

  (* FileNames *)

  FILE_LOG = 'log.log';
  FILE_FILTER = '*.map';

  (* Debug *)

  EVENT_START = '--- Powered by IskaTreK - Copyright(c) 2004 --- '#13#10' --- Arquivo: "%s" ---';
  EVENT_ERROR = 'Ocorreu o seguinte erro: %s';
  EVENT_TALK = 'Chamando: [%s]';
  EVENT_CREATE = '%s criado com sucesso.';
  EVENT_RESOLUTION = 'Resolu��o da janela: %dx%d.';
  EVENT_REGISTRY = 'Classe %s registrada com sucesso.';
  EVENT_INSTANCE = '%s instanciado com sucesso.';
  EVENT_FOUND = 'Arquivo encontrado: "%s"';
  EVENT_DISPLAYMODE = 'Adaptador de modo de display encontrado.';

  (* Errors *)

  ERROR_SITE = 'Ocorreu um erro dentro de: %s';
  ERROR_EXISTS = '%s j� existente.';
  ERROR_REGISTRY = 'Imposs�vel registrar classe %s.';
  ERROR_INSTANCE = 'Imposs�vel instanciar classe %s.';
  ERROR_MUSICLOADER = 'Imposs�vel carregar m�sica.';
  ERROR_MUSICPERFORMANCE = 'Erro na performance.';
  ERROR_INITAUDIO = 'Imposs�vel inicializar audio.';
  ERROR_PATH = 'Imposs�vel pegar Path do audio.';
  ERROR_VOLUME = 'Imposs�vel definir volume';
  ERROR_LOAD = 'Imposs�vel carregar audio';
  ERROR_DOWNLOAD = 'Imposs�vel baixar audio';
  ERROR_NOSEGMENT = 'N�o existe o segmento de audio';
  ERROR_PLAYFAIL = 'Falha ao iniciar audio.';
  ERROR_NOTFOUND = 'Imposs�vel encontrar o arquivo: "%s"';

  (* Messages *)

  MSG_OPEN = 'Abrir';
  MSG_SAVE = 'Salvar';
  MSG_CONFIRM = 'Confirmar';
  MSG_BOXEXIT = 'Voc� realmente deseja sair?';
  MSG_BOXSAVE = 'Deseja salvar as altera��es em %s?';

  (* Colors *)

  clRed = $FFFF0000;
  clGreen = $FF00FF00;
  clBlue = $FF0000FF;
  clWhite = $FFFFFFFF;
  clBlack = $FF000000;
  clAqua = $FF00FFFF;
  clFuchsia = $FFFF00FF;
  clYellow = $FFFFFF00;
  clMaroon = $000080;
  clOlive = $008080;
  clNavy = $800000;
  clPurple = $800080;
  clTeal = $808000;
  clGray = $808080;
  clSilver = $C0C0C0;
  clLime = $00FF00;
  clLtGray = $C0C0C0;
  clDkGray = $808080;
  
implementation

end.


