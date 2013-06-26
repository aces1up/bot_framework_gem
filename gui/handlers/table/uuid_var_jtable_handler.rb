

class UUIDVarTableHandler < javax.swing.table.DefaultTableModel

  include BotFrameWorkModules
  include GetValueAtHelperModule

  attr_accessor :data, :columns, :gui_handle, :init_model, :init_renderer, :render_klass

  def initialize( args={} )

    @data = ThreadSafe::Hash.new

    @columns ||= {
          :function  =>   :shown,
          :status    =>   :shown,
          :proxy     =>   :shown,
          :info      =>   :shown,
          :error     =>   :shown,
          :login     =>   :shown,
          :visitors  =>   :shown,
          :uuid      =>   :shown
    }

    @init_model     = true                     #<--- we init model on object creation on default
    @init_renderer  = true                     #<--- we also init renderer on default on object creation.

    @gui_handle     = :dashboard_table         #<--- handle of the jtable this is initializing
    @render_klass   = DashboardTableRenderer   #<--- the klass of our renderer for
                                               #<--- initialization
    @gui_element = nil
    @renderer    = nil

    @lock = Mutex.new
    super()

    load_object_args( args ) if !args.empty?

    init_columns()
    init_gui_element()
    init_model()       if @init_model
    init_renderer()    if @init_renderer
  end

  def init_gui_element()
      @gui_element = DashboardGuiController.instance.get_gui_handle( @gui_handle )
  end

  def init_renderer()
      @renderer = DashboardTableRenderer.new( @gui_element, self )
  end

  def init_model()
      @gui_element.model = self
  end

  def init_columns()
      @columns.each do |column, column_type|
          add_column( column ) if column_type == :shown
      end
  end

  def getColumnCount
    #make sure we only return the count for the number of
    #columns that are set as shown.
    return @columns.count{|column, column_type| column_type == :shown}
  end

  def getRowCount
      return @data.size
  end

  def isCellEditable(row, col)
      false
  end

  def getValueAt(row, col)
      column_var = col_to_sym( getColumnName(col) )
      begin
          @data[ @data.keys[row] ][column_var].to_s
      rescue => err
          "unknown"
      end
  end

  def update_data( thread )
      @columns.each do |column, column_type|

          thread_var = thread.get_var( column )

          @data[thread.uuid][column] = thread_var if thread_var
          @data[thread.uuid][column] ||= 'unknown'
      end
  end

  def update( thread=nil )
    @lock.synchronize {

      begin
          thread ||= Thread.current
          return if !thread.uuid

          uuid = thread.uuid

          @data[uuid] ||= {}
          @data[uuid][:uuid] = uuid
  
          update_data( thread )
          fireTableDataChanged()

      rescue => err
          puts "got jtable update error : #{err.message}\n#{err.backtrace.join("\n")}"
      end
    }
  end

end




