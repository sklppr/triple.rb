require "set"

# ∞ as a constant.
INFINITY = 1.0/0

# Edges with cost.
Edge = Struct.new :from, :to, :cost

# Project encapsulation.
class Project
  
  def initialize
    @nodes = SortedSet.new
    @edges = []
  end
  
  # Add a node to the project graph.
  def add_node(node)
    @nodes.add node
  end
  
  # Add multiple nodes at once.
  def add_nodes(*nodes)
    @nodes.merge nodes
  end
  
  # Add an edge to the project graph.
  def add_edge(from, to, cost)
    @edges << Edge.new(from, to, cost)
  end
  
  # Set maximum project duration by adding an edge with negative duration as weight.
  def max_duration=(duration)
    nodes = @nodes.to_a
    add_edge(nodes.last, nodes.first, -duration)
    duration
  end
  
  # Determine earliest and latest starting times by using the
  # Tripe algorithm to find longest paths between all nodes.
  def triple
    
    # Determine number of nodes.
    n = @nodes.size
    
    # Initialize distance matrix (n×n) with 0 in the diagonal and -∞ elsewhere.
    d = Array.new(n) { |i| Array.new(n) { |j| i == j ? 0 : -INFINITY } }
    
    # For all edges (i,j) ∈ E: set d[i,j] = σ(i,j)
    @edges.each { |e| d[e.from][e.to] = e.cost }
    
    # For all nodes v ∈ V:
    @nodes.each do |v|
      
      # For all pairs (i,j) with i,j ∈ V\{v} and d[i,v] > -∞:
      nodes_ij = @nodes - [v]
      nodes_ij.each do |i|
        next if d[i][v] == -INFINITY
        nodes_ij.each do |j|
          
          # If the path i->v->j is longer than i->j until now, set i->v->j as new distance between i and j.
          d[i][j] = [ d[i][j], d[i][v] + d[v][j] ].max
          
        end
      end
    end
    
    # Return earliest and lates starting times.
    result = {}
    @nodes.each { |i| result[i] = { es: d[0][i], ls: -d[i][0] } }
    result
    
  end
  
  # Read project from PSPLIB file.
  def self.from_psp_file(filename)
    
    project = Project.new
    
    File.open(filename, "r") do |file|
      
      # First line contains number of activities.
      n = file.gets.split("\t")[0].to_i
      
      # The next n+2 lines contain activities.
      (n+2).times do |i|
        
        # Add node.
        project.add_node i
        
        # Tokenize line.
        tokens = file.gets.split("\t")
        
        # Third token is number of successors.
        n_succ = tokens[2].to_i
        
        # Add an edge for each successor.
        n_succ.times do |k|
          j = tokens[3 + k].to_i
          c = tokens[3 + k + n_succ].gsub(/[^-\d]/, "").to_i
          project.add_edge(i, j, c)
        end
        
      end
      
    end
    
    project
    
  end
  
end
