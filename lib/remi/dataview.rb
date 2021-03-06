module Remi
  module Dataview
    extend self

    @chart = nil
    @tpl = nil

    def view(dataset)
      create_google_table(dataset)
      table_tpl
      
      unless File.directory?(RemiConfig.work_dirname)
        FileUtils.mkdir_p(RemiConfig.work_dirname)
      end

      file_name = "visualr-#{dataset.name}-#{Digest::MD5.hexdigest Time.new.to_s}.html"
      viewdata_fullpath = File.join(RemiConfig.work_dirname,file_name);
      File.open(viewdata_fullpath,'w') do |f|
        f.write table_tpl.result(binding)
      end

      Launchy.open(viewdata_fullpath)
    end


    def create_google_table(dataset)
      google_table = GoogleVisualr::DataTable.new

      Datastep.read dataset do |ds|
        if ds._N_ == 1
          # Send all columns as strings, until we have some better typing rules
          dataset.vars.each do |var_name,var_key|
            google_table.new_column('string', var_name)
          end
        end

        if ds._N_ <= 1000
          google_table.add_rows(1)

          ivar = -1
          dataset.vars.each do |var_name,var_obj|
            google_table.set_cell(dataset._N_ - 1,ivar += 1, dataset[var_name].to_s)
          end
        else
          break
        end
      end

=begin
      # I would like to support number formats in some fashion like this
      google_table.set_cell(0, 0, 'Mike'  )
      google_table.set_cell(0, 1, {:v => 10000, :f => '$10,000'})
      google_table.set_cell(0, 2, true  )
      google_table.set_cell(1, 0, 'Jim'   )
      google_table.set_cell(1, 1, {:v => 8000 , :f => '$8,000' })
      google_table.set_cell(1, 2, false )
=end

      opts   = { :showRowNumber => true }
      @chart = GoogleVisualr::Interactive::Table.new(google_table, opts)
    end


    def table_tpl
      @tpl = ERB.new <<-EOF.unindent
      <!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Strict//EN' 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd'>
      <html xmlns='http://www.w3.org/1999/xhtml'>
        <head>
          <meta http-equiv='content-type' content='text/html; charset=utf-8'/>
          <title>
            Google Visualization API Sample
          </title>
          <script src='https://www.google.com/jsapi'></script>

            <%= @chart.to_js('table')%>

        </head>
        <body>
          <div id='table' style='height: 800px; width: 1000px;'></div>
        </body>
       </html>
      EOF
    end
  end
end
