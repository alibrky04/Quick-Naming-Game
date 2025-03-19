extends Control

@onready var chart: Chart = $Chart

const score_count = 5

var f1: Function
var user_name: String = GameManager.currentProfile

func _ready():
	var last_scores: Array = SQLManager.get_last_scores(GameManager.currentProfile, score_count)
	
	# Create x values as game indices (1, 2, 3, ...) instead of timestamps
	var x: PackedFloat32Array = range(1, last_scores.size() + 1)
	var y: Array = last_scores
	
	# Define chart properties
	var cp: ChartProperties = ChartProperties.new()
	cp.colors.frame = Color("#161a1d")
	cp.colors.background = Color.TRANSPARENT
	cp.colors.grid = Color("#283442")
	cp.colors.ticks = Color("#283442")
	cp.colors.text = Color.WHITE_SMOKE
	cp.draw_bounding_box = false
	cp.title = "Son 5 Oyundaki Puanlar"
	cp.x_label = "Oyun Numarası"
	cp.y_label = "Puan"
	cp.x_scale = 1
	cp.y_scale = 10
	cp.interactive = true
	
	# Create function for plotting scores
	f1 = Function.new(
		x, y, "Score",  
		{ 
			color = Color("#36a2eb"), 
			marker = Function.Marker.CIRCLE,  
			type = Function.Type.LINE, 
			interpolation = Function.Interpolation.STAIR 
		}
	)
	
	# Plot the scores
	chart.plot([f1], cp)
