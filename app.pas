
{$reference 'PresentationFramework.dll'}
{$reference 'PresentationCore.dll'}
{$reference 'WindowsBase.dll'}
{$apptype windows}

uses System.Windows;
uses System.Windows.Controls;
uses System.Windows.Markup;
uses System.IO;
uses mw;
uses gn;

begin
  Application.Create.Run(new mw.MainWindow());
end.