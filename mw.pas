unit mw;
{$reference 'PresentationFramework.dll'}
{$reference 'PresentationCore.dll'}
{$reference 'WindowsBase.dll'}
{$apptype windows}

uses System.Windows;
uses System.Windows.Controls;
uses System.Windows.Markup;
uses System.IO;
uses gn;

type
  MainWindow = class(Window)
  public
    fs := new FileStream('mw.xaml', FileMode.Open);
    rootElement := System.Windows.DependencyObject(XamlReader.Load(fs));
    
    NowNoteContent := TextBox(LogicalTreeHelper.FindLogicalNode(rootElement, 'NowNoteContent'));
    NotesList := ListBox(LogicalTreeHelper.FindLogicalNode(rootElement, 'NotesList'));
    AddNote_btn := Button(LogicalTreeHelper.FindLogicalNode(rootElement, 'AddNote_btn'));
    DropNote_btn := Button(LogicalTreeHelper.FindLogicalNode(rootElement, 'DropNote_btn'));
    RenameNote_btn := Button(LogicalTreeHelper.FindLogicalNode(rootElement, 'RenameNote_btn'));
    DropAllNotes_btn := Button(LogicalTreeHelper.FindLogicalNode(rootElement, 'DropAllNotes_btn'));
    SaveNote_btn := Button(LogicalTreeHelper.FindLogicalNode(rootElement, 'SaveNote_btn'));
    OpenNote_btn := Button(LogicalTreeHelper.FindLogicalNode(rootElement, 'OpenNote_btn'));
    Help_btn := Button(LogicalTreeHelper.FindLogicalNode(rootElement, 'Help_btn'));
    
    about_data :string := 'Название программы: Pas Notes'
                         + char(13) +'Предназначение: простое и удобное ведение заметок'
                         + char(13) +'Разработчик: Тохов Ислам М'
                         + char(13) +'Инструметы: Visual Studio, PascalaABC.NET'
                         + char(13) +'Год разраюотки: 2024'
                         + char(13) +'Версия: 0.85r';
    
    private procedure InitializeComponent();
    begin
      NowNoteContent.TextChanged+=NowNoteContent_TextChanged;
      AddNote_btn.Click += AddNote_btn_Click;
      DropNote_btn.Click += DropNote_btn_Click;
      RenameNote_btn.Click += RenameNote_btn_Click;
      DropAllNotes_btn.Click += DropAllNotes_btn_Click;
      SaveNote_btn.Click += SaveNote_btn_Click;
      OpenNote_btn.Click += OpenNote_btn_Click;
      Help_btn.Click += Help_btn_Click;
    end;
    
    public constructor();
    begin
      InitializeComponent();
      self.Content := rootElement;
      self.Height := 480;
      self.Width := 800;
      self.Title := 'Pas Notes';
      NotesList.SelectedIndex := 0;
    end;
    
    public Notes: List<string> := new List<string>();
    private id := 0;
    private old_id := 0;
    
    private procedure ListBoxItem_Selected(sender: object; e: RoutedEventArgs);
    begin
      if (Notes.Count > 0) then
      begin
        Notes[old_id] := NowNoteContent.Text;
      end
      else Notes.Add(NowNoteContent.Text);
      id := NotesList.Items.IndexOf(sender);
      NowNoteContent.Text := Notes[id];
      old_id := id;     
    end;
    
    private procedure AddNote_btn_Click(sender: object; e: RoutedEventArgs);
    begin
      var new_note_name := getNewName();
      if (new_note_name <> string.Empty) then
      begin
        var new_note := new ListBoxItem();
        var temp := RoutedEventHandler(ListBoxItem_Selected);
        new_note.Selected += temp;
        new_note.Content := new_note_name;
        
        NotesList.Items.Add(new_note);
        Notes.Add(string.Empty);
        
        NotesList.SelectedIndex := NotesList.Items.Count - 1;
      end;
    end;
    
    private function getNewName(def_name: string := 'Заметка'): string;
    begin
      var name := new gn.getNewNoteName(def_name);
      name.ShowDialog();
      result := name.getNewName();
    end;
    
    private procedure DropNote_btn_Click(sender: object; e: RoutedEventArgs);
    begin
      if (NotesList.Items.Count <> 0) and (id >= 0) then 
      begin
        id := NotesList.SelectedIndex;
        NotesList.Items.Remove(NotesList.Items.GetItemAt(id));
        Notes.RemoveAt(id);
        id := 0;
        if (Notes.Count > 0) then
          NowNoteContent.Text := Notes[0]
        else NowNoteContent.Text := '';
        old_id := 0;
        if (NotesList.Items.Count > 0) then
          NotesList.SelectedIndex := 0;
      end;
    end;
    
    private procedure RenameNote_btn_Click(sender: object; e: RoutedEventArgs);
    begin
      if (NotesList.SelectedItem <> nil) then
      begin
        var lbi: ListBoxItem := ListBoxItem(NotesList.Items.GetItemAt(id));
        var new_note_name := getNewName(lbi.Content.ToString());
        if (new_note_name <> string.Empty) then
          lbi.Content := (new_note_name);
      end;
    end;
    
    private procedure DropAllNotes_btn_Click(sender: object; e: RoutedEventArgs);
    begin
      id := 0;
      old_id := 0;
      
      NotesList.Items.Clear();
      Notes.Clear();
      
      NowNoteContent.Text := '';
    end;
    
    private procedure SaveNote_btn_Click(sender: object; e: RoutedEventArgs);
    begin
      if (NotesList.SelectedItem <> nil) then
      begin
        var lbi: ListBoxItem := ListBoxItem(NotesList.Items.GetItemAt(id));
        var NoteName := lbi.Content.ToString();

        // Configure open file dialog box
        var dialog := new Microsoft.Win32.SaveFileDialog();
        dialog.FileName := NoteName; // Default file name
        dialog.DefaultExt := '.txt'; // Default file extension
        dialog.Filter := 'Text documents (.txt)|*.txt'; // Filter files by extension
        
        // Show open file dialog box
        var res: System.Nullable<boolean> := dialog.ShowDialog();
        
        // Process open file dialog box results
        if (res = true) then
        begin
          // Save document
          var filename: string := dialog.FileName;
          //Pass the filepath and filename to the StreamWriter Constructor
          var sw: StreamWriter := new StreamWriter(filename);
          //Write a line of text
          sw.Write(Notes[NotesList.SelectedIndex]);
          //Close the file
          sw.Close();
        end;
      end;
    end;
    
    private procedure NowNoteContent_TextChanged(sender: object; e: TextChangedEventArgs);
    begin
      if ((id >= 0) and (Notes.Count > 0)) then
        Notes[id] := NowNoteContent.Text;
    end;
    
    private procedure OpenNote_btn_Click(sender: object; e: RoutedEventArgs);
    begin
      // Configure open file dialog box
      var dialog := new Microsoft.Win32.OpenFileDialog();
      dialog.DefaultExt := '.txt'; // Default file extension
      dialog.Filter := 'Text documents (.txt)|*.txt'; // Filter files by extension
      
      // Show open file dialog box
      var res: System.Nullable<boolean> := dialog.ShowDialog();
      
      // Process open file dialog box results
      if (res = true) then
      begin
          // Save document
        var filename: string := dialog.FileName;
        var note: string;
          //Pass the file path and file name to the StreamReader constructor
        var sr: StreamReader := new StreamReader(filename);
          //Read the first line of text
        note := sr.ReadToEnd();
          //Continue to read until you reach end of file
        NowNoteContent.Text := note;
          //close the file
        sr.Close();
      end;
    end;
    
    private procedure Help_btn_Click(sender: object; e: RoutedEventArgs);
    begin
      MessageBox.Show(self.about_data, 'Справка', MessageBoxButton.OK);
    end;
  
  end;

begin

end.
