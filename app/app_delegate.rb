class AppDelegate
  def applicationDidFinishLaunching(notification)
    buildMenu
    buildWindow
  end

  def buildWindow
    @mainWindow = NSWindow.alloc.initWithContentRect([[240, 180], [480, 360]],
      styleMask: NSTitledWindowMask|NSClosableWindowMask|NSMiniaturizableWindowMask|NSResizableWindowMask,
      backing: NSBackingStoreBuffered,
      defer: false)
    @mainWindow.title = NSBundle.mainBundle.infoDictionary['CFBundleName']
    @mainWindow.orderFrontRegardless
    @button0 = buildButton(0)
    @button1 = buildButton(1)
    mergeButton
    @columnSelector = NSPopUpButton.alloc.initWithFrame([[30, 280],[100, 22]], pullsDown: false)
    @mainWindow.contentView.addSubview(@columnSelector)
  end
  
  def buildButton(tag)
    button = NSButton.alloc.initWithFrame([[90+(120*tag), 320], [100, 22]])
    button.title = "File #{tag+1}"
    button.bezelStyle = NSTexturedRoundedBezelStyle
    button.target = self
    button.action = 'showDirectory:'
    button.tag = tag
    @mainWindow.contentView.addSubview(button)
  end
  
  def mergeButton
    button = NSButton.alloc.initWithFrame([[190, 20], [100, 22]])
    button.title = 'Merge'
    button.bezelStyle = NSTexturedRoundedBezelStyle
    button.target = self
    button.action = 'merge'
    @mainWindow.contentView.addSubview(button)
  end
  
  def merge
    mapping = {}
    column = @columnSelector.titleOfSelectedItem
    @file0.each do |row|
      mapping[row[column]] = row
    end
    
    @file1.each do |row|
      original = mapping[row[column]]
      if original
        original.merge(row)
      else
        puts "Original not found for: #{column} => #{row[column]}"
      end
    end
    rows = mapping.values
    file2 = MotionCSV::Table.new(rows.first.headers)
    rows.each do |row|
      file2 << row
    end
    if filename = saveNewCvs
      file2.write(filename)
    end
  end
  def showDirectory(sender)
    puts sender.inspect
    dialog = NSOpenPanel.openPanel
    dialog.canChooseFiles = true
    dialog.canChooseDirectories = false
    dialog.allowedFileTypes = ['csv']
    if dialog.runModal == NSOKButton
      filename = dialog.filename
      case sender.tag
      when 0
        @file0 = MotionCSV.parse(File.read(filename))
        populateColumns
      when 1
        @file1 = MotionCSV.parse(File.read(filename))
      end
    end
  end
  def saveNewCvs
    dialog =NSSavePanel.savePanel
    if dialog.runModal ==NSOKButton
      dialog.filename
    end
  end
  
  def populateColumns
    @file0.headers.each do |header|
      @columnSelector.addItemWithTitle(header)
    end
  end
  
end
