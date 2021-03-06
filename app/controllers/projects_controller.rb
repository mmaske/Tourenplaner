class ProjectsController < ApplicationController
  # GET /projects
  # GET /projects.xml

  def index
    @projects = Project.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml { render :xml => @projects }
    end
  end

  # GET /projects/1
  # GET /projects/1.xml
  def show
    @project = Project.find(params[:id])
    @json = Node.find(:all).to_gmaps4rails
    respond_to do |format|
      format.html # show.html.erb
      format.xml { render :xml => @project }
    end
  end

  # GET /projects/new
  # GET /projects/new.xml
  def new
    @project = Project.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml { render :xml => @project }
    end
  end

  # GET /projects/1/edit
  def edit
    @project = Project.find(params[:id])
    @title = "Edit project"
  end


  # POST /projects
  # POST /projects.xml
  def create
    @project = Project.new(params[:project])

    respond_to do |format|
      if @project.save
        format.html { redirect_to(@project, :notice => 'Project was successfully created.') }
        format.xml { render :xml => @project, :status => :created, :location => @project }
      else
        format.html { render :action => "new" }
        format.xml { render :xml => @project.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /projects/1
  # PUT /projects/1.xml
  def update
    @project = Project.find(params[:id])

    respond_to do |format|
      if @project.update_attributes(params[:project])
        format.html { redirect_to(@project, :notice => 'Project was successfully updated.') }
        format.xml { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml { render :xml => @project.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.xml
  def destroy
    @project = Project.find(params[:id])
    @project.destroy

    respond_to do |format|
      format.html { redirect_to(projects_url) }
      format.xml { head :ok }
    end
  end

  def optimize
    @project = Project.find(:all)
    @nodes = Node.find(:all)
    @vehicles = Vehicle.find(:all)
    if File.exist?("VRP_v1_Input_Instanz1.inc")
      File.delete("VRP_v1_Input_Instanz1.inc")
    end

######print set#####
    fil=File.new("VRP_v1_Input_Instanz1.inc", "w") # w für write
    printf(fil, "set i / \n")

    @nodes.each { |so|
      if so.depot?
        printf(fil, "d" + "\n")
      else
        printf(fil, "i" + so.id.to_s + "\n")
      end } #schreibe sie in die include datei
    printf(fil, "/" + "\n\n")

    printf(fil, " k / \n")
    @vehicles.each { |so| printf(fil, "v" + so.id.to_s + "\n") } #schreibe sie in die include datei
    printf(fil, "/;" + "\n\n")

#####print distance matrix#####
    printf(fil, "table c(i,j)  "+"\n" + "%-5s", "")
    @nodes.each do |i|
      if i.depot?
        printf(fil, "%-30s", "d")
      else
        printf(fil, "%-30s", "i" +i.id.to_s)
      end
    end
    printf(fil, "\n")
    @nodes.each do |i|
      if i.depot?
        printf(fil, "%-5s", "d")
      else
        printf(fil, "%-5s", "i" +i.id.to_s)
      end
      @nodes.each do |j|
        if i!=j
        x=Gmaps4rails.destination(
            {"from" => "#{i.street}+#{i.city}", "to" => "#{j.street}+#{j.city}"})
        distance = x.first["distance"]["value"]
        printf(fil, "%-30f", distance)
        else
        printf(fil, "%-30s", "9999999999999999999999999")

        end

      end
      printf(fil, "\n")
    end
    printf(fil, ";" + "\n\n")

####print duration matrix#####
    printf(fil, "table t(i,j) "+"\n" + "%-5s", "")
    @nodes.each do |i|
      if i.depot?
        printf(fil, "%-30s", "d")
      else
        printf(fil, "%-30s", "i" +i.id.to_s)
      end
    end
    printf(fil, "\n")
    @nodes.each do |i|
      if i.depot?
        printf(fil, "%-5s", "d")
      else
        printf(fil, "%-5s", "i" +i.id.to_s)
      end
      @nodes.each do |j|
        if i!=j
        x=Gmaps4rails.destination(
            {"from" => "#{i.street}+#{i.city}", "to" => "#{j.street}+#{j.city}"})
        distance = x.first["duration"]["value"]
        printf(fil, "%-30f", distance)
        else
        printf(fil, "%-30s", "9999999999999999999999999")

        end

      end
      printf(fil, "\n")
    end
    printf(fil, ";" + "\n\n")

#####Depot Knoten definieren#####
    printf(fil, "Kundenknoten(i) = yes;\n")

    @nodes.each do |li|
      if li.depot?
        printf(fil, "Kundenknoten('d') = no;"+"\n")
        #printf(fil, "Kundenknoten('d#{li.id.to_s}') = no;"+"\n")
      end
    end
    printf(fil, "\n\n")

#####Fahrzeugkapazitäten definieren#####
    printf(fil, "parameter cap(k) /"+"\n")

    @vehicles.each do |k|
      printf(fil, "%-5s", "v" +k.id.to_s)
      cap=k.Capacity
      printf(fil, "%-5f", cap)
      printf(fil, "\n")
    end
    printf(fil, "/;" + "\n\n")

#####Nachfrage definieren#####
    printf(fil, "parameter d(i) /"+"\n")

    @nodes.each do |k|
      if k.depot?
        printf(fil, "%-5s", "d","")
        printf(fil, "%-5f", "0")
        printf(fil, "\n")
      else
        printf(fil, "%-5s", "i" +k.id.to_s)

        demand=k.demand
        printf(fil, "%-5f", demand)
        printf(fil, "\n")
      end
    end
    printf(fil, "/;" + "\n\n")
    fil.close

    system "gams VRP"

    respond_to do |format|
      format.html { redirect_to(projects_url) }
      format.xml { render :xml => @project }
    end
  end



#    if File.exist?("Transportmengen_v2.txt") # datei mit der vorherigen lösung löschen
#      File.delete("Transportmengen_v2.txt")
#    end


#    system "gams Transportmodell_v2" # rufe gams auf und arebite das transportmodell ab
## system "C:\\Progra~\\Gams23,7\\gams Transportmodell_v2"                             # rufe gams auf und arebite das transportmodell ab
#    @transport_links = TransportLink.find(:all)
#    render :template => "transport_links/index"
#  end

#  def read_transportation_quantities
#    if File.exist?("Transportmengen_v2.txt") # datei mit der vorherigen lösung löschen


#    fi=File.open("Transportmengen_v2.txt", "r") # lösung einlesen und in die datenbank speichern
#    fi.each { |line| # printf(f,line)
#      sa=line.split(";")
#      sa0=sa[0].delete "l "
#      sa3=sa[3].delete " \n"
#      al=TransportLink.find_by_id(sa0)
#      al.transport_quantity=sa3
#      al.save

#    }

#    fi.close
#     end
#    @transport_links = TransportLink.find(:all)
#    render :template => "transport_links/index"
#
#  end


#  def delete_production_quantities
#    @transport_links = TransportLink.find(:all)
#    @transport_links.each { |li|
#      li.transport_quantity=0.0
#      li.save
#    }

#    render :template => "transport_links/index"

#  end

#  def read_and_show_ofv
#    if File.exists?("Zielfunktionswert_v2.txt")
#    fi=File.open("Zielfunktionswert_v2.txt", "r")
#    line=fi.readline
#    sa=line.split(" ")
#   @objective_function_value=sa[1]
#    else
#    @objective_function_value=nil
#    end
#    @transport_links = TransportLink.find(:all)
#    render :template => "transport_links/index"
#  end
end
