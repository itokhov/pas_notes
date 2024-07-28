unit gn;
{$reference 'PresentationFramework.dll'}
{$reference 'PresentationCore.dll'}
{$reference 'WindowsBase.dll'}
{$apptype windows}

uses System.Windows;
uses System.Windows.Controls;
uses System.Windows.Markup;
uses System.IO;


type
  getNewNoteName = class (Window)
    private name: string;
    private wasCreate: boolean := false;
    
    private fs := new FileStream('gnnn.xaml', FileMode.Open);
    rootElement := System.Windows.DependencyObject(XamlReader.Load(fs));
    
    NoteName := TextBox(LogicalTreeHelper.FindLogicalNode(rootElement, 'NoteName'));
    CreateNote_btn := Button(LogicalTreeHelper.FindLogicalNode(rootElement, 'CreateNote_btn'));
    CancelCreating_btn := Button(LogicalTreeHelper.FindLogicalNode(rootElement, 'CancelCreating_btn'));
    
    private procedure InitializeComponent();
    begin
      NoteName.TextChanged += NoteName_TextChanged;
      CreateNote_btn.Click += CreateNote_btn_Click;
      CancelCreating_btn.Click += CancelCreating_btn_Click;
    end;
    
    public constructor(def_name: string := 'Заметка');
    begin
      InitializeComponent();
      self.Content := rootElement;
      self.Height := 160;
      self.Width := 320;
      name := def_name;
      NoteName.Text := name;
    end;
    
    private procedure CreateNote_btn_Click(sender: object; e: RoutedEventArgs);
    begin
      wasCreate := true;
      if (name = '') then
        wasCreate := false
      else
        self.Close();
    end;
    
    private procedure CancelCreating_btn_Click(sender: object; e: RoutedEventArgs);
    begin
      wasCreate := false;
      self.Close();
    end;
    
    public function getNewName(): string;
    begin
      if (wasCreate and (NoteName.Text <> '')) then
        result := name
      else
        result := string.Empty;     
    end;
    
    private procedure NoteName_TextChanged(sender: object; e: TextChangedEventArgs);
    begin
      name := NoteName.Text;
    end;
  end;

begin
  
end.
