import java.awt.*;

String[] windows_DataSelect(String text) {
  FileDialog dialog = new FileDialog((Frame)null, text);
  dialog.setMode(FileDialog.LOAD);
  dialog.setVisible(true);
  dialog.setResizable(true);
  return new String[] {dialog.getDirectory(),dialog.getFile(),dialog.getDirectory()+File.separator+dialog.getFile()};
}
