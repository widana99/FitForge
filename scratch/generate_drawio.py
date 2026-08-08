import xml.etree.ElementTree as ET

def create_drawio_xml():
    mxfile = ET.Element('mxfile', {
        'host': 'Electron',
        'modified': '2026-08-04T10:30:00.000Z',
        'agent': 'Mozilla/5.0',
        'version': '21.6.8',
        'type': 'device'
    })
    
    diagram = ET.SubElement(mxfile, 'diagram', {
        'id': 'fitforge-chen-erd',
        'name': 'FitForge ERD Notasi Chen'
    })
    
    model = ET.SubElement(diagram, 'mxGraphModel', {
        'dx': '1800',
        'dy': '1400',
        'grid': '1',
        'gridSize': '10',
        'guides': '1',
        'tooltips': '1',
        'connect': '1',
        'arrows': '1',
        'fold': '1',
        'page': '1',
        'pageScale': '1',
        'pageWidth': '2200',
        'pageHeight': '1600',
        'math': '0',
        'shadow': '0'
    })
    
    root = ET.SubElement(model, 'root')
    
    # Base cells required by draw.io
    ET.SubElement(root, 'mxCell', {'id': '0'})
    ET.SubElement(root, 'mxCell', {'id': '1', 'parent': '0'})
    
    node_id_counter = 2
    
    def get_id():
        nonlocal node_id_counter
        curr = str(node_id_counter)
        node_id_counter += 1
        return curr

    # Color Constants matching user image style
    ENTITY_STYLE = "rounded=0;whiteSpace=wrap;html=1;fillColor=#263646;strokeColor=#1a2530;fontColor=#ffffff;fontStyle=1;fontSize=14;"
    RELATION_STYLE = "rhombus;whiteSpace=wrap;html=1;fillColor=#263646;strokeColor=#1a2530;fontColor=#ffffff;fontStyle=1;fontSize=13;"
    ATTR_STYLE = "ellipse;whiteSpace=wrap;html=1;fillColor=#263646;strokeColor=#1a2530;fontColor=#ffffff;fontSize=12;"
    EDGE_STYLE = "endArrow=none;html=1;rounded=0;strokeColor=#263646;strokeWidth=2;fontSize=12;fontColor=#263646;fontStyle=1;"

    nodes = {}

    def add_node(key, label, x, y, w, h, style):
        nid = get_id()
        cell = ET.SubElement(root, 'mxCell', {
            'id': nid,
            'value': label,
            'style': style,
            'vertex': '1',
            'parent': '1'
        })
        ET.SubElement(cell, 'mxGeometry', {
            'x': str(x),
            'y': str(y),
            'width': str(w),
            'height': str(h),
            'as': 'geometry'
        })
        nodes[key] = nid
        return nid

    def add_edge(source_key, target_key, label=""):
        eid = get_id()
        cell = ET.SubElement(root, 'mxCell', {
            'id': eid,
            'value': label,
            'style': EDGE_STYLE,
            'edge': '1',
            'parent': '1',
            'source': nodes[source_key],
            'target': nodes[target_key]
        })
        ET.SubElement(cell, 'mxGeometry', {
            'relative': '1',
            'as': 'geometry'
        })
        return eid

    # --- 1. ENTITIES ---
    # Top Admin
    add_node('Admin', 'Admin', 950, 80, 160, 60, ENTITY_STYLE)
    
    # Middle Level
    add_node('Exercise', 'Exercise', 200, 360, 160, 60, ENTITY_STYLE)
    add_node('Workout', 'Workout', 1600, 360, 160, 60, ENTITY_STYLE)
    
    # Center User
    add_node('User', 'User', 950, 750, 160, 60, ENTITY_STYLE)
    
    # Bottom Level
    add_node('WorkoutHistory', 'WorkoutHistory', 300, 1200, 180, 60, ENTITY_STYLE)
    add_node('Schedule', 'Schedule', 950, 1200, 160, 60, ENTITY_STYLE)
    add_node('WeightLog', 'WeightLog', 1500, 1200, 160, 60, ENTITY_STYLE)

    # --- 2. RELATIONSHIPS ---
    add_node('rel_admin_ex', 'Mengelola', 550, 220, 130, 70, RELATION_STYLE)
    add_node('rel_admin_wo', 'Mengelola', 1300, 220, 130, 70, RELATION_STYLE)
    
    add_node('rel_wo_ex', 'Terdiri Dari', 950, 355, 150, 75, RELATION_STYLE)
    
    add_node('rel_user_history', 'Melakukan', 550, 980, 130, 70, RELATION_STYLE)
    add_node('rel_user_schedule', 'Mengatur', 950, 980, 130, 70, RELATION_STYLE)
    add_node('rel_user_weight', 'Mencatat', 1300, 980, 130, 70, RELATION_STYLE)
    
    add_node('rel_wo_history', 'Dicatat Pada', 850, 1200, 120, 60, RELATION_STYLE) # Alternative link or side link

    # --- 3. ATTRIBUTES ---
    # Admin Attributes
    add_node('attr_admin_id', '<u>admin_id</u>', 800, 20, 110, 45, ATTR_STYLE)
    add_node('attr_admin_nama', 'nama', 930, 10, 100, 45, ATTR_STYLE)
    add_node('attr_admin_email', 'email', 1050, 10, 100, 45, ATTR_STYLE)
    add_node('attr_admin_role', 'role', 1170, 20, 100, 45, ATTR_STYLE)

    # Exercise Attributes
    add_node('attr_ex_id', '<u>exercise_id</u>', 30, 260, 110, 45, ATTR_STYLE)
    add_node('attr_ex_nama', 'nama_gerakan', 160, 240, 115, 45, ATTR_STYLE)
    add_node('attr_ex_otot', 'target_muscle', 300, 250, 115, 45, ATTR_STYLE)
    add_node('attr_ex_level', 'level', 30, 330, 100, 45, ATTR_STYLE)
    add_node('attr_ex_type', 'type', 30, 400, 100, 45, ATTR_STYLE)
    add_node('attr_ex_duration', 'duration', 30, 470, 100, 45, ATTR_STYLE)
    add_node('attr_ex_desc', 'description', 150, 490, 110, 45, ATTR_STYLE)

    # Workout Attributes
    add_node('attr_wo_id', '<u>workout_id</u>', 1800, 260, 110, 45, ATTR_STYLE)
    add_node('attr_wo_nama', 'nama_workout', 1650, 240, 120, 45, ATTR_STYLE)
    add_node('attr_wo_kat', 'category', 1500, 250, 110, 45, ATTR_STYLE)
    add_node('attr_wo_diff', 'difficulty', 1810, 340, 110, 45, ATTR_STYLE)
    add_node('attr_wo_dur', 'est_duration', 1810, 420, 110, 45, ATTR_STYLE)
    add_node('attr_wo_cal', 'est_calories', 1750, 490, 110, 45, ATTR_STYLE)

    # Relasi Terdiri Dari Attributes (Relationship Attributes)
    add_node('attr_rel_sets', 'sets', 830, 280, 90, 40, ATTR_STYLE)
    add_node('attr_rel_reps', 'reps', 950, 265, 90, 40, ATTR_STYLE)
    add_node('attr_rel_rest', 'rest_time', 1070, 280, 100, 40, ATTR_STYLE)

    # User Attributes
    add_node('attr_user_uid', '<u>uid</u>', 710, 600, 100, 45, ATTR_STYLE)
    add_node('attr_user_nama', 'nama', 830, 580, 100, 45, ATTR_STYLE)
    add_node('attr_user_email', 'email', 950, 570, 100, 45, ATTR_STYLE)
    add_node('attr_user_gender', 'gender', 1070, 580, 100, 45, ATTR_STYLE)
    add_node('attr_user_dob', 'dateOfBirth', 1190, 600, 110, 45, ATTR_STYLE)
    add_node('attr_user_weight', 'weight', 670, 670, 95, 45, ATTR_STYLE)
    add_node('attr_user_height', 'height', 670, 740, 95, 45, ATTR_STYLE)
    add_node('attr_user_goal', 'workoutGoal', 1290, 670, 110, 45, ATTR_STYLE)
    add_node('attr_user_level', 'trainingLevel', 1290, 740, 110, 45, ATTR_STYLE)
    add_node('attr_user_streak', 'streak', 730, 830, 95, 45, ATTR_STYLE)
    add_node('attr_user_workouts', 'totalWorkouts', 850, 850, 115, 45, ATTR_STYLE)
    add_node('attr_user_calories', 'totalCalories', 990, 850, 115, 45, ATTR_STYLE)
    add_node('attr_user_dur', 'totalDuration', 1130, 830, 115, 45, ATTR_STYLE)

    # WorkoutHistory Attributes
    add_node('attr_wh_id', '<u>history_id</u>', 120, 1140, 110, 45, ATTR_STYLE)
    add_node('attr_wh_date', 'date', 110, 1220, 100, 45, ATTR_STYLE)
    add_node('attr_wh_dur', 'duration', 160, 1300, 100, 45, ATTR_STYLE)
    add_node('attr_wh_cal', 'caloriesBurned', 280, 1330, 120, 45, ATTR_STYLE)
    add_node('attr_wh_rate', 'rating', 420, 1330, 100, 45, ATTR_STYLE)

    # Schedule Attributes
    add_node('attr_sch_id', '<u>schedule_id</u>', 780, 1320, 110, 45, ATTR_STYLE)
    add_node('attr_sch_day', 'dayOfWeek', 910, 1340, 105, 45, ATTR_STYLE)
    add_node('attr_sch_time', 'time', 1030, 1340, 95, 45, ATTR_STYLE)
    add_node('attr_sch_act', 'isActive', 1140, 1320, 100, 45, ATTR_STYLE)

    # WeightLog Attributes
    add_node('attr_wl_id', '<u>log_id</u>', 1420, 1310, 100, 45, ATTR_STYLE)
    add_node('attr_wl_w', 'weight', 1540, 1330, 100, 45, ATTR_STYLE)
    add_node('attr_wl_d', 'date', 1660, 1310, 100, 45, ATTR_STYLE)

    # --- 4. CONNECTORS ---
    # Entity -> Attributes
    add_edge('Admin', 'attr_admin_id')
    add_edge('Admin', 'attr_admin_nama')
    add_edge('Admin', 'attr_admin_email')
    add_edge('Admin', 'attr_admin_role')

    add_edge('Exercise', 'attr_ex_id')
    add_edge('Exercise', 'attr_ex_nama')
    add_edge('Exercise', 'attr_ex_otot')
    add_edge('Exercise', 'attr_ex_level')
    add_edge('Exercise', 'attr_ex_type')
    add_edge('Exercise', 'attr_ex_duration')
    add_edge('Exercise', 'attr_ex_desc')

    add_edge('Workout', 'attr_wo_id')
    add_edge('Workout', 'attr_wo_nama')
    add_edge('Workout', 'attr_wo_kat')
    add_edge('Workout', 'attr_wo_diff')
    add_edge('Workout', 'attr_wo_dur')
    add_edge('Workout', 'attr_wo_cal')

    add_edge('rel_wo_ex', 'attr_rel_sets')
    add_edge('rel_wo_ex', 'attr_rel_reps')
    add_edge('rel_wo_ex', 'attr_rel_rest')

    add_edge('User', 'attr_user_uid')
    add_edge('User', 'attr_user_nama')
    add_edge('User', 'attr_user_email')
    add_edge('User', 'attr_user_gender')
    add_edge('User', 'attr_user_dob')
    add_edge('User', 'attr_user_weight')
    add_edge('User', 'attr_user_height')
    add_edge('User', 'attr_user_goal')
    add_edge('User', 'attr_user_level')
    add_edge('User', 'attr_user_streak')
    add_edge('User', 'attr_user_workouts')
    add_edge('User', 'attr_user_calories')
    add_edge('User', 'attr_user_dur')

    add_edge('WorkoutHistory', 'attr_wh_id')
    add_edge('WorkoutHistory', 'attr_wh_date')
    add_edge('WorkoutHistory', 'attr_wh_dur')
    add_edge('WorkoutHistory', 'attr_wh_cal')
    add_edge('WorkoutHistory', 'attr_wh_rate')

    add_edge('Schedule', 'attr_sch_id')
    add_edge('Schedule', 'attr_sch_day')
    add_edge('Schedule', 'attr_sch_time')
    add_edge('Schedule', 'attr_sch_act')

    add_edge('WeightLog', 'attr_wl_id')
    add_edge('WeightLog', 'attr_wl_w')
    add_edge('WeightLog', 'attr_wl_d')

    # Entity -> Relationship Connections (with Cardinality Labels)
    add_edge('Admin', 'rel_admin_ex', '1')
    add_edge('rel_admin_ex', 'Exercise', 'Many')

    add_edge('Admin', 'rel_admin_wo', '1')
    add_edge('rel_admin_wo', 'Workout', 'Many')

    add_edge('Exercise', 'rel_wo_ex', 'Many')
    add_edge('rel_wo_ex', 'Workout', 'Many')

    add_edge('User', 'rel_user_history', '1')
    add_edge('rel_user_history', 'WorkoutHistory', 'Many')

    add_edge('User', 'rel_user_schedule', '1')
    add_edge('rel_user_schedule', 'Schedule', 'Many')

    add_edge('User', 'rel_user_weight', '1')
    add_edge('rel_user_weight', 'WeightLog', 'Many')

    # Write formatted XML string
    tree = ET.ElementTree(mxfile)
    ET.indent(tree, space="  ", level=0)
    
    file_path = r"c:\Users\Lenovo\.gemini\antigravity\scratch\fitforge\fitforge_erd_chen.drawio"
    tree.write(file_path, encoding='utf-8', xml_declaration=True)
    print(f"File created successfully at {file_path}")

if __name__ == '__main__':
    create_drawio_xml()
