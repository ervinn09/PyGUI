import tkinter as tk
from tkinter import ttk, filedialog
from tkinter import messagebox
import os
import random
import csv
import time
import matlab.engine



initial_folder = "C:/Users/admin/Downloads/BA/BA/noise"

class ValidatedEntryWithPlaceholder:
    def __init__(self, root, placeholder, x, y, width=10,command=None,validation_func=None):
        self.root = root
        self.placeholder = placeholder
        self.entry_var = tk.StringVar()
       
        style = ttk.Style()
        style.configure("Placeholder.TEntry", foreground="grey")
       
        self.validation_func = validation_func if validation_func else self.default_validation

        self.entry = ttk.Entry(
            root,
            width=width,
            textvariable=self.entry_var,
            validate="key",
            validatecommand=(root.register(self.validate_input), '%P'),
            style= "Placeholder.TEntry",
        )
        self.entry['state'] = 'disabled'
        self.entry.insert(0, placeholder)
        self.entry.bind('<FocusIn>', self.on_entry_focus_in)
        self.entry.bind('<FocusOut>', self.on_entry_focus_out)
        self.entry.place(x=x, y=y)
       
        self.trace_id = None

        self.callback = command
   
    def set_placeholder(self, new_placeholder):
        self.placeholder = new_placeholder
        self.entry_var.set(new_placeholder)
        self.entry.delete(0, tk.END)
        self.entry.insert(0, new_placeholder)
       
    def enable(self):
         self.entry['state'] = 'normal'
         self.entry.delete(0, tk.END)
         

    def disable(self):
         self.entry['state'] = 'disabled'
         if self.trace_id is not None:
            self.entry_var.trace_remove("write", self.trace_id)
            self.trace_id = None
   
    def delete(self):
          self.entry['state'] = 'enabled'
          self.entry['validate'] = 'none'
          self.entry.delete(0, tk.END)
          self.entry.insert(0, self.placeholder)
          self.entry['validate'] = 'key'
          self.entry['state'] = 'disabled'
         
    def delete_lost(self):
          self.entry['state'] = 'enabled'
          self.entry['validate'] = 'none'
          self.entry.delete(0, tk.END)
         


    def validate_input(self, new_value):
        # Check if the entered text is the default placeholder
        if new_value == self.placeholder:
            return True
        # Return True if the input is valid, False otherwise
        return self.validation_func(new_value)
   
   
    # Define a default validation function
    
    def default_validation(self, new_value):
        return new_value == "" or (new_value.isdigit() and 0 <= int(new_value) )
    

    def on_entry_focus_in(self, event):
        if self.entry_var.get() == self.placeholder:
            self.entry.delete(0, tk.END)
           

    def on_entry_focus_out(self, event):
        
        if not self.entry_var.get():
            self.entry.insert(0, self.placeholder)

        # Call the callback function if provided
        if self.callback:
            self.callback(self.entry_var.get())

    def get(self):
        return self.entry_var.get()
   
    def setempty(self):
        self.entry_var.set("-")
       
    def increase(self,value):
        self.entry.insert(0, str(value + 1))
    def decrease(self,value):
        self.entry.insert(0, str(value - 1))

def custom_validation(new_value):
    # Return True if the input is valid, False otherwise
    return new_value == "" or (new_value.isdigit() and 0 < int(new_value) <= 20000)

def custom_validationaslin(new_value):
    
    if new_value in ("", "-"):
        return True
    
    if new_value[0] == "-":
        return (new_value[1:].isdigit()) and int(new_value)
    else:
        return (new_value.isdigit()) and int(new_value)
    
def custom_validationtcfer(new_value):
    if new_value in (""):
        return True
    
    return new_value.isdigit() and int(new_value) > 0

def common_validation(new_value, selected_option):
    if selected_option == "amrnb":
        return new_value == "" or new_value == "1-8" or (new_value.isdigit() and 0 <= int(new_value) <= 8)

    if selected_option == "amrwb":
        return new_value == "" or new_value == "1-9" or (new_value.isdigit() and 0 <= int(new_value) <= 9)

    if selected_option == "evs":
        return new_value == "" or new_value == "1-12" or (new_value.isdigit() and 0 <= int(new_value) <= 12)

    if selected_option == "opus":
      try:
         return new_value == "" or new_value == "6-256" or  0 <= float(new_value) <= 256
         if float(new_value) < 6:
               entry_c1_amnrb.entry.config(highlightbackground="red", highlightcolor="red")
      except ValueError:
         return False
     
     
    if selected_option == "g722":
        return new_value == "" or new_value == "1-3" or (new_value.isdigit() and 1 <= int(new_value) <= 3)

    if selected_option == "g711":
        return new_value == 1 or new_value == "1" or new_value == ""

    if selected_option == "skip":
        return new_value == "-"  # Skip logic (you can adjust this based on your specific requirements)


def custom_validation_c1amnrb(new_value):
    return common_validation(new_value, selected_option_codecs.get())


def custom_validation_c2amnrb(new_value):
    return common_validation(new_value, selected_option_codecs1.get())

def custom_validation_c3amnrb(new_value):
    return common_validation(new_value, selected_option_codecs2.get())

   

def compare_entries(*args):

    value1 = entry1.get()
    value2 = entry2.get()
   
    if checkbox_var.get() and checkbox_var1.get():
        if entry2.get() == "":
            entry1.delete()
            entry1.enable()
        else:                
            v1 = int(value1) if value1 and value1 != "0-20000" else 0
            v2 = int(value2) if value2 and value2 != "0-20000" else 0

            if v1 > v2 or v1 == v2:
               entry1.delete()
               entry1.enable()
            elif v2 < v1:
               entry2.delete()
               entry2.enable()

def on_option_selected(*args):
    option = selected_option.get()
   
    if option in {"highpass", "bandpass"}:
        checkbox['state'] = 'normal'
        if option == "highpass":
            message3.place_forget()
            message2.place_forget()
            message1.place(x=150,y=200)
    else:
        checkbox_var.set(False)
        checkbox['state'] = 'disabled'
                                   
    if option in {"lowpass", "bandpass"}:
        checkbox1['state'] = 'normal'
        if option == "lowpass":
            message1.place_forget()
            message3.place_forget()
            message2.place(x=150,y=200)
        if option == "bandpass":
            message1.place_forget()
            message2.place_forget()
            message3.place(x=150,y=200)
    else:
        checkbox_var1.set(False)
        checkbox1['state'] = 'disabled'
   
    if option == "-":
        message1.place_forget()
        message2.place_forget()
        message3.place_forget()


def checked_pb(*args):
    check = checkbox_var.get()
    check1 = checkbox_var1.get()
   
    if check:
        entry1.enable()
       
    else:
        entry1.disable()
        entry1.delete()
       
    if check1:
        entry2.enable()
    else:
        entry2.disable()
        entry2.delete()

def increase_value():
    current_value = entry_timclp.get()
    if current_value:
        current_value = int(entry_timclp.get())
        entry_timclp.delete_lost()
        entry_timclp.increase(current_value)
 
def decrease_value():
    current_value = entry_timclp.get()
    if current_value:
       current_value = int(entry_timclp.get())
       if current_value > 0:
          entry_timclp.delete_lost()
          entry_timclp.decrease(current_value)

def choose_random_file(fpath):
    files = [f for f in os.listdir(fpath) if os.path.isfile(os.path.join(fpath, f))]
    if files:
        random_file = random.choice(files)
        file_path = os.path.join(fpath, random_file)
        return entry_varbgn.set(file_path)
    else:
        return entry_varbgn.set("No files in the folder")

def clear_values():
    selected_option.set("-")
    checkbox_var8.set(False)
    entry_aslin.delete()
    entry_aslin.disable()
    checkbox_var7.set(False)
    entry_aslout.delete()
    entry_aslout.disable()
    checkbox_var3.set(False)
    checkbox_var4.set(False)
    checkbox4['state'] = 'disabled'
    checkbox_var5.set(False)
    checkbox5['state'] = 'disabled'
    scale['state'] = 'disabled'
    label_value.place_forget()
    entry_timclp.delete()
    entry_timclp.disable()
    checkbox_var2.set(False)
    checkbox_cl2.set(False)
    scale_cl['state'] = 'disabled'
    label_value_cl.place_forget()
    checkbox_var6.set(False)
    entry_wbng.delete()
    entry_wbng.disable()
    checkbox_var9.set(False)
    entry_pmnru.delete()
    entry_pmnru.disable()
    checkbox_bgnv.set(False)
    entry_bgn.delete(0, tk.END)
    entry_bgn['state'] = 'disabled'
    entry_bgn2.delete()
    entry_bgn2.disable()
    selected_option_codecs.set("skip")
    entry_c1_amnrb.delete()
    entry_c1_amnrb.setempty()
    entry_c1_amnrb.disable()
    selected_option_cod_plcModus.set("-")
    button_cod1_plc['state'] = 'disabled'
    scale_fer1['state'] = 'disabled'
    label_value_fer1.place_forget()
    
    selected_option_codecs1.set("skip")
    entry_c2_amnrb.delete()
    entry_c2_amnrb.setempty()
    entry_c2_amnrb.disable()
    selected_option_cod_plcModus1.set("-")
    button_cod2_plc['state'] = 'disabled'
    scale_fer2['state'] = 'disabled'
    label_value_fer2.place_forget()
    
    selected_option_codecs2.set("skip")
    entry_c3_amnrb.delete()
    entry_c3_amnrb.setempty()
    entry_c3_amnrb.disable()
    selected_option_cod_plcModus2.set("-")
    button_cod3_plc['state'] = 'disabled'
    scale_fer3['state'] = 'disabled'
    label_value_fer3.place_forget()
 

def get_final_values_filter(event=None):
   
    #dist_post_codec
    dist_post_codec = "-"
   
    #filter
    filter_value = selected_option.get()
   
    #timeclipping
    timeclp = "x" if checkbox_var3.get() else "-"
       
    #wbgn
    wbgn = "x" if checkbox_var6.get() else "-"
     
    #p50mnru
    p50mnru = "x" if checkbox_var9.get() else "-"
   
    #bgn
    bgn = "x" if checkbox_bgnv.get() else "-"
   
    #bgn_file
    bgn_file = "-" if entry_varbgn.get() == "" else entry_varbgn.get()
    
   
    #clipping
    clipping = "x" if checkbox_cl2.get() else "-"
   
    #arb_filter
    arb_filter = "x" if checkbox_var2.get() else "-"
   
    #asl_in
    asl_in = "x" if checkbox_var8.get() else "-"
   
    #asl_out
    asl_out = "x" if checkbox_var7.get() else "-"
   
    #codec1
    codec1 = selected_option_codecs.get()
   
    #codec2
    codec2 = selected_option_codecs1.get()
   
    #codec3
    codec3 = selected_option_codecs2.get()
   
    #plcMode1
    plcMode1 = selected_option_cod_plcModus.get()
   
    #plcMode2
    plcMode2 = selected_option_cod_plcModus1.get()
   
    #plcMode3
    plcMode3 = selected_option_cod_plcModus2.get()
    
    if entry_wbng.get() =="-" :
        entry_wbng.delete()
    #wbgn_snr
    wbgn_snr = "NaN" if wbgn == "-" else entry_wbng.get()
   
    if entry_bgn2.get() =="-" :
        entry_bgn2.delete()
    #bgn_snr
    bgn_snr = "NaN" if bgn == "-" else entry_bgn2.get()
   
    #tc_fer
    tc_fer = int(round(scale_fr_error_rate.get(), 2) * 100) if checkbox_var4.get() else "NaN"
   
    if entry_timclp.get() == "":
        checkbox_var5.set(False)
        entry_timclp.disable()
    #tc_nburst
    tc_nburst = entry_timclp.get() if checkbox_var5.get() else "NaN"
   
    #cl_th
    cl_th = round(scale_clipping.get(), 2) if clipping == "x" else "NaN"
   
    #bandpass
    if selected_option.get() == "bandpass":
        if entry2.get() == "" or entry2.get() == "0-20000":
            messagebox.showerror("Error","enter a value on filter tab -> bp_high")
            return
        if entry1.get() == "" or entry1.get() == "0-20000":
            messagebox.showerror("Error","enter a value on filter tab -> bp_low")
            return
        bp_high = entry2.get()
        bp_low = entry1.get()

   
    #bp_low
    if selected_option.get() == "highpass":
        if entry1.get() == "" or entry1.get() == "0-20000":
            messagebox.showerror("Error","enter a value on filter tab -> bp_low")
            return
        bp_low = entry1.get()
        bp_high = "NaN"

   
    #bp_high
    if selected_option.get() == "lowpass":
        if entry2.get() == "" or entry2.get() == "0-20000":
            messagebox.showerror("Error","enter a value on filter tab -> bp_high")
            return
        bp_high = entry2.get()
        bp_low = "NaN"
   
    if selected_option.get() == "-":
        bp_high = "NaN"
        bp_low = "NaN"
        
    if entry_pmnru.get() =="-" :
        entry_pmnru.delete()
    #p50_q
    p50_q = "NaN" if p50mnru == "-" else entry_pmnru.get()
   
    #bMode1
    bMode1 = "NaN" if selected_option_codecs.get() == "skip" else entry_c1_amnrb.get()
    if bMode1 == entry_c1_amnrb.placeholder:
        messagebox.showerror("Error on tab codec1","enter a value on bMode1")
        return
   
    #bMode2
    bMode2 = "NaN" if selected_option_codecs1.get() == "skip" else entry_c2_amnrb.get()
    if bMode2 == entry_c2_amnrb.placeholder:
        messagebox.showerror("Error on tab codec2","enter a value on bMode2")
        return
   
    #bMode3
    bMode3 = "NaN" if selected_option_codecs2.get() == "skip" else entry_c3_amnrb.get()
    if bMode3 == entry_c3_amnrb.placeholder:
        messagebox.showerror("Error on tab codec3","enter a value on bMode3")
        return
   
    #FER1
    FER1 = "NaN" if selected_option_codecs.get() == "skip" else round(scale_fer1var.get(), 2)
   
    #FER2
    FER2 = "NaN" if selected_option_codecs1.get() == "skip" else round(scale_fer2var.get(), 2)
   
    #FER3
    FER3 = "NaN" if selected_option_codecs2.get() == "skip" else round(scale_fer3var.get(), 2)
   
    #asl_in
    if entry_aslin.get() =="-" :
        entry_aslin.delete()
    asl_in_level = "NaN" if asl_in == "-" else entry_aslin.get()
   
    #asl_out
    if entry_aslout.get() =="-" :
        entry_aslout.delete()
    asl_out_level = "NaN" if asl_out == "-" else entry_aslout.get()
    
   
    condition = [dist_post_codec, filter_value, timeclp, wbgn, p50mnru, bgn,
                 bgn_file, clipping, arb_filter, asl_in, asl_out, codec1,
                 codec2, codec3, plcMode1, plcMode2, plcMode3, wbgn_snr,
                 bgn_snr, tc_fer, tc_nburst, cl_th, bp_low, bp_high, p50_q,
                 bMode1, bMode2, bMode3, FER1, FER2, FER3, asl_in_level,
                 asl_out_level]
   
    saved_conditions.append(condition)
     
    update_element_labels(len(saved_conditions))
   
    # Add items from the special list to the listbox
    listbox.insert(tk.END, f"Condition {len(saved_conditions)}")
   
   
def validate_input_no(*args):
       value = entry_wbng.get()
       if checkbox_var6.get() == False:
           entry_wbng.disable()
           entry_wbng.delete()
       else:
          entry_wbng.enable()
          if value == "":
             entry_wbng.delete()
             entry_wbng.enable()
          else:
              if not value.isdigit() or int(value) == 0:
                 entry_wbng.delete()
                 entry_wbng.enable()

def asl_out_val(*args):
    value = entry_aslout.get()
    if checkbox_var7.get() == False:
        entry_aslout.disable()
        entry_aslout.delete()
    else:
        entry_aslout.enable()
        if value == "":
           entry_aslout.delete()
           entry_aslout.enable()
        else:
            if not value.isdigit() or int(value) == 0:
                entry_aslout.delete()
                entry_aslout.enable()
                
def asl_in_val(*args):
    value = entry_aslin.get()
    if checkbox_var8.get() == False:
        entry_aslin.disable()
        entry_aslin.delete()
    else:
        entry_aslin.enable()
        if value == "":
           entry_aslin.delete()
           entry_aslin.enable()
        else:
            if not value.isdigit() or int(value) == 0:
                entry_aslin.delete()
                entry_aslin.enable()

def asl_p50_val(*args):
    value = entry_pmnru.get()
    if checkbox_var9.get() == False:
        entry_pmnru.disable()
        entry_pmnru.delete()
    else:
        entry_pmnru.enable()
        if value == "":
           entry_pmnru.delete()
           entry_pmnru.enable()
        else:
            if not value.isdigit() or int(value) == 0:
                entry_pmnru.delete()
                entry_pmnru.enable()
                
    
        
def on_scale_change(value):
         formatted_value = "{:.2f}".format(float(value))
         label_value.config(text=f"{formatted_value}")

def on_scale_change_cl(value):
        formatted_value = "{:.2f}".format(float(value))
        label_value_cl.config(text=f"{formatted_value}")
       
def on_scale_change_fer1(value):
        formatted_value = "{:.2f}".format(float(value))
        label_value_fer1.config(text=f"{formatted_value}")
       
def on_scale_change_fer2(value):
        formatted_value = "{:.2f}".format(float(value))
        label_value_fer2.config(text=f"{formatted_value}")

def on_scale_change_fer3(value):
        formatted_value = "{:.2f}".format(float(value))
        label_value_fer3.config(text=f"{formatted_value}")

qw = "NaN"
def on_checkbox_change():
    if checkbox_var4.get():
        label_value.place(x=515,y=255)
        scale['state'] = '!disabled'
    else:
        label_value.place_forget()
        scale_fr_error_rate.set(None)
        scale['state'] = 'disabled'        

def check_timeclipp():
    if checkbox_var3.get() :
        checkbox4['state'] = 'normal'
    else:
        checkbox_var4.set(False)
        on_checkbox_change()
        checkbox4['state'] = 'disabled'
   
    if checkbox_var3.get() :
        checkbox5['state'] = 'normal'
    else:
        enable_disable_entry_tcfer()
        checkbox_var5.set(0)
        checkbox5['state'] = 'disabled'
   

def clipping_scale():
    if checkbox_cl2.get():
        label_value_cl.place(x=370,y=250)
        scale_cl['state'] = '!disabled'
    else:
        label_value_cl.place_forget()
        scale_cl['state'] = 'disabled'  
   
       
def activate_entrybgn():
    if checkbox_bgnv.get():
       entry_bgn2.enable()
       entry_bgn['state'] = 'normal'
       entry_bgn.delete(0, tk.END)
    else:
        entry_bgn2.disable()
        entry_bgn.delete(0, tk.END)
        entry_bgn['state'] = 'disabled'
   

def choose_file(event):
    if entry_bgn['state'] == 'normal':
        file_path = filedialog.askopenfilename(
            initialdir=initial_folder,
            filetypes=[("WAV files", "*.wav")]
        )
        entry_varbgn.set(file_path)
       
def enable_codecs1_plc(*args) :
    if entry_c1_amnrb.entry_var != "skip" :
        button_cod1_plc.config(state=tk.NORMAL)
    else :
        button_cod1_plc.entry_var = "-"
        button_cod1_plc.config(state=tk.DISABLED)
       
def enable_codec_entry(entry, button, selected_option,scale,scale_var,label):
    options = {
        "skip": ("-", 'key'),
        "amrnb": ("1-8", 'key'),
        "amrwb": ("1-9", 'key'),
        "evs": ("1-12", 'key'),
        "opus": ("6-256", 'key'),
        "g722": ("1-3", 'key'),
        "g711": ("1", 'key'),
    }
    if selected_option != "skip":
      button.config(state=tk.NORMAL)
      entry.enable()
      entry.entry['validate'] = 'none'

      placeholder, validation_key = options.get(selected_option, ("", None,None))
      entry.set_placeholder(placeholder)

      if validation_key:
         entry.entry['validate'] = validation_key
      scale["state"] = "!disabled"
     
      label.place(x=370,y=410)
     
    if selected_option == "skip":
        entry.entry['validate'] = 'none'
        entry.set_placeholder("")
        entry.disable()
        button.current(0)
        button.config(state=tk.DISABLED)
        label.place_forget()
        scale_var.set(None)
        scale["state"] = "disabled"

def enable_codecs1_arg(*args):
    enable_codec_entry(entry_c1_amnrb, button_cod1_plc, selected_option_codecs.get(),scale_fer1,scale_fer1var,label_value_fer1)
       
def enable_codecs2_arg(*args):
    enable_codec_entry(entry_c2_amnrb, button_cod2_plc, selected_option_codecs1.get(),scale_fer2,scale_fer2var,label_value_fer2)
   
def enable_codecs3_arg(*args):
    enable_codec_entry(entry_c3_amnrb, button_cod3_plc, selected_option_codecs2.get(),scale_fer3,scale_fer3var,label_value_fer3)


def on_tab_change(event):
    notebook.index(notebook.select())
   
def enable_disable_entry_tcfer():
    if checkbox_var5.get():
        entry_timclp.enable()
    else:
        entry_timclp.disable()

def populate_guide(text_widget):
    # Insert guide content into the text widget
    guide_content = """
    Welcome to the User Guide! 
    
    This guide will walk you through the steps required to input 
    the preferred degradands values across the tabs and generate
    conditional tables for your MATLAB Tool.

    --instructions on how to use our application :--
        
    1.After launching the programm you'll find a tabbed interface
      with ten tabs labeled staring from "anli".

    --Inputing values:--
    2. Navigate to Tab "anli"
    3. (if applicable) enable the checkbox and enter a value
    4. repeat step 2. and 3. for other tabs
       (the widgets differ from tab to tab)
    
    --Generating Conditional Tables--
    
    Once you have your inputted values across tabs:
        
    5. Review your inputs to ensure accuracy.
    6. Click on the "Add Condition" button to create a 
       conditional table.  
    7. Click "Show content" to see the inputted values for the
       selected condition
    8. If a created condition is not needed, select the condition 
       and click "delete"
    9. Click "Clear" if you want to reset the input values of interface
    8. "Save csv" after creating condition and select where 
        the csv file will be saved.
    11. The last step is "Launch", where you have to choose one 
        of the created csv and from that the degraded signals 
        will be created.
    
    --Feedback:--
              We welcome your feedback on the interface. 
              Please feel free to reach out to us with any
              suggestions or issues you encounter.
    
    """

    # Enable the text widget to insert text
    text_widget.config(state="normal")
    text_widget.insert(tk.END, guide_content)
    # Disable the text widget to make it read-only
    text_widget.config(state="disabled")

root = tk.Tk()

# Create a style for the notebook
style = ttk.Style()
style.configure("TNotebook", padding=(15, 15, 250, 200), tabposition='nw')  # Adjust the padding as needed
style.configure('Bold.TNotebook.Tab', font=('Helvetica', '10', 'bold'))

# Create a notebook (tabbed interface)
notebook = ttk.Notebook(root, style="TNotebook")

# Create tabs
tab_guide = ttk.Frame(notebook)
tab7_anli = ttk.Frame(notebook)
tab1_filter = ttk.Frame(notebook)
tab2_timeclp = ttk.Frame(notebook)
tab3_arbf = ttk.Frame(notebook)
tab4_clipp = ttk.Frame(notebook)
tab5_wbn = ttk.Frame(notebook)
tab6_mru = ttk.Frame(notebook)
tab9_bnf = ttk.Frame(notebook)
tab10_c1 = ttk.Frame(notebook)
tab11_c2 = ttk.Frame(notebook)
tab12_c3 = ttk.Frame(notebook)
tab8_anlo = ttk.Frame(notebook)


# Add tabs to the notebook
tab_guide = ttk.Frame(notebook)
notebook.add(tab_guide, text="guide")
notebook.add(tab7_anli, text="anli")
notebook.add(tab1_filter, text="filter")
notebook.add(tab2_timeclp, text="timeclipping")
notebook.add(tab3_arbf, text="arb filter")
notebook.add(tab4_clipp, text="clipping")
notebook.add(tab5_wbn, text="wbn")
notebook.add(tab6_mru, text="mru")
notebook.add(tab9_bnf, text="bnf")
notebook.add(tab10_c1, text="codec1")
notebook.add(tab11_c2, text="codec2")
notebook.add(tab12_c3, text="codec3")
notebook.add(tab8_anlo, text="anlo")


notebook.select(tab_guide)

# Create a text widget for the guide
guide_text = tk.Text(tab_guide, wrap="word", state="disabled", bg="light gray")
guide_text.place(relx=0.05, rely=0.05, relwidth=0.9, relheight=0.9)

# Add scrollbars to the text widget
scrollbar = ttk.Scrollbar(tab_guide, orient="vertical", command=guide_text.yview)
scrollbar.place(relx=0.95, rely=0.05, relheight=0.9)
guide_text.config(yscrollcommand=scrollbar.set)

# Populate the guide text widget
populate_guide(guide_text)


# Bind the tab change event to a function
notebook.bind("<<NotebookTabChanged>>", on_tab_change)

# Pack the notebook to make it visible
notebook.pack(expand=1, fill="both")

notebook.place(relx=0.5, rely=1.1, anchor='s', relwidth=1, relheight=1)

initial_width = 860
initial_height = 730

root.geometry(f"{initial_width}x{initial_height}")

root.title("MATLAB database generation tool")
root.resizable(False,False)


entry_varbgn = tk.StringVar()

# Create the Entry widget
entry_bgn = tk.Entry(tab9_bnf, textvariable=entry_varbgn, width=30,state="readonly")
entry_bgn.place(x=220, y=250)

# Bind the event handler to the <Button-1> event for the entry
entry_bgn.bind("<Button-1>", choose_file)

style = ttk.Style()
style.configure("TCombobox", fieldbackground="grey", bordercolor="grey")
style.configure("Horizontal.TSeparator", background="grey")
style.configure("Vertical.TSeparator", background="grey")
style.configure("TLabel", font=('Calibri', 15, 'bold'), foreground='#333333')
style.configure("TRadiobutton", font=("Verdana", 11), background="#ecf0f1", foreground="#2c3e50", borderwidth=1 , padding=(10, 5), relief="groove")

# Create a variable to hold the state of the checkbox
checkbox_var = tk.BooleanVar()
checkbox_var1 = tk.BooleanVar()
checkbox_var2 = tk.BooleanVar()
checkbox_var3 = tk.BooleanVar()
checkbox_var4 = tk.BooleanVar()
checkbox_var5 = tk.BooleanVar()
checkbox_var6 = tk.BooleanVar()
checkbox_var7 = tk.BooleanVar()
checkbox_var8 = tk.BooleanVar()
checkbox_var9 = tk.BooleanVar()
checkbox_cl1 = tk.BooleanVar()
checkbox_cl2 = tk.BooleanVar()
checkbox_bgnv = tk.BooleanVar()

style.configure("Larger.TCheckbutton", width=8, font=('Verdana', 11))

checkbox_var.trace_add("write", checked_pb)
checkbox_var1.trace_add("write", checked_pb)

# Use a themed Tkinter Checkbutton for a modern look
checkbox = ttk.Checkbutton(tab1_filter, text="bp low", variable=checkbox_var, state= "disabled",command=checked_pb,
    style="Larger.TCheckbutton")
checkbox.place(x=340,y=320)

checkbox1 = ttk.Checkbutton(tab1_filter, text="bp high", variable=checkbox_var1, state= "disabled",command=checked_pb,
    style="Larger.TCheckbutton")
checkbox1.place(x=220,y=320)

checkbox2 = ttk.Checkbutton(tab3_arbf, text="arb_filter", variable=checkbox_var2, state= "enabled")
checkbox2.place(x=200,y=135)

checkbox3 = ttk.Checkbutton(tab2_timeclp, text="activate", variable=checkbox_var3, state= "enabled",command=check_timeclipp)
checkbox3.place(x=100,y=130)

checkbox4 = ttk.Checkbutton(tab2_timeclp, text="tc_fer", variable=checkbox_var4,command=on_checkbox_change, state= "disabled")
checkbox4.place(x=180,y=195)

checkbox5 = ttk.Checkbutton(tab2_timeclp, text="tc_nburst", variable=checkbox_var5, state= "disabled",command=enable_disable_entry_tcfer)
checkbox5.place(x=180,y=310)

checkbox6 = ttk.Checkbutton(tab5_wbn, text="wbgn", variable=checkbox_var6, state= "enabled",command=validate_input_no)
checkbox6.place(x=230,y=170)

checkbox7 = ttk.Checkbutton(tab8_anlo, text="asl_out", variable=checkbox_var7, state= "enabled",command=asl_out_val)
checkbox7.place(x=230,y=170)

checkbox8 = ttk.Checkbutton(tab7_anli, text="asl_in", variable=checkbox_var8, state= "enabled",command=asl_in_val)
checkbox8.place(x=230,y=180)

checkbox9 = ttk.Checkbutton(tab6_mru, text="p50mnru", variable=checkbox_var9, state= "enabled",command=asl_p50_val)
checkbox9.place(x=230,y=170)


checkbox_clth =ttk.Checkbutton(tab4_clipp, text="cl_th", variable=checkbox_cl2, state= 'enabled',command=clipping_scale)
checkbox_clth.place(x=160,y=165)

checkbox_bgn =ttk.Checkbutton(tab9_bnf, text="bgn", variable=checkbox_bgnv, state= 'enabled',command=activate_entrybgn)
checkbox_bgn.place(x=160,y=195)

scale_fr_error_rate = tk.DoubleVar()
scale_clipping = tk.DoubleVar()
scale_fer1var = tk.DoubleVar()
scale_fer2var = tk.DoubleVar()
scale_fer3var = tk.DoubleVar()

scale = ttk.Scale(tab2_timeclp, variable=scale_fr_error_rate, from_=0, to=1, length=180, command=on_scale_change, state="disabled")
scale.place(x=350,y=255)
label_value = ttk.Label(tab2_timeclp, text="NaN")
label_value.place(x=515,y=255)

scale_cl = ttk.Scale(tab4_clipp, variable=scale_clipping,from_=0,to=1,length=180,command=on_scale_change_cl,state='disabled')
scale_cl.place(x=200,y=250)
label_value_cl = ttk.Label(tab4_clipp, text="NaN")
label_value_cl.place(x=370,y=250)

scale_fer1 = ttk.Scale(tab10_c1, variable=scale_fer1var,from_=0,to=1,length=180,command=on_scale_change_fer1,state='disabled')
scale_fer1.place(x=200,y=410)
label_value_fer1 = ttk.Label(tab10_c1, text="NaN")
label_value_fer1.place(x=370,y=410)

scale_fer2 = ttk.Scale(tab11_c2, variable=scale_fer2var,from_=0,to=1,length=180,command=on_scale_change_fer2,state='disabled')
scale_fer2.place(x=200,y=410)
label_value_fer2 = ttk.Label(tab11_c2, text="NaN")
label_value_fer2.place(x=370,y=410)

scale_fer3 = ttk.Scale(tab12_c3, variable=scale_fer3var,from_=0,to=1,length=180,command=on_scale_change_fer3,state='disabled')
scale_fer3.place(x=200,y=410)
label_value_fer3 = ttk.Label(tab12_c3, text="NaN")
label_value_fer3.place(x=370,y=410)

options_codecs = ["skip","amrnb","amrwb","evs","opus","g711","g722"]
options = ["highpass", "bandpass", "lowpass"]

selected_option = tk.StringVar()
selected_option_codecs = tk.StringVar()
selected_option_codecs1 = tk.StringVar()
selected_option_codecs2 = tk.StringVar()
selected_option_cod_plcModus = tk.StringVar()
selected_option_cod_plcModus1 = tk.StringVar()
selected_option_cod_plcModus2 = tk.StringVar()


# Set the default option
selected_option.set("-")
selected_option.trace_add("write", on_option_selected)

#selected_option_codecs.trace_add("write", callback)

#selected_option_codecs.trace_add("write", on_option_selected)

button = ttk.Combobox(tab10_c1,textvariable=selected_option_codecs,width=12,state='readonly')
button.place(x=90,y=160)

button.bind("<<ComboboxSelected>>", enable_codecs1_arg)



button1 = ttk.Combobox(tab11_c2,textvariable=selected_option_codecs1,width=12,state='readonly')
button1.place(x=90,y=160)
button1.bind("<<ComboboxSelected>>", enable_codecs2_arg)


button2 = ttk.Combobox(tab12_c3,textvariable=selected_option_codecs2,width=12,state='readonly')
button2.place(x=90,y=160)
button2.bind("<<ComboboxSelected>>", enable_codecs3_arg)


button_cod1_plc = ttk.Combobox(tab10_c1,textvariable=selected_option_cod_plcModus,width=10,state='readonly')
button_cod1_plc.place(x=300,y=310)
button_cod1_plc.config(state=tk.DISABLED)

button_cod2_plc = ttk.Combobox(tab11_c2,textvariable=selected_option_cod_plcModus1,width=10,state='readonly')
button_cod2_plc.place(x=300,y=310)
button_cod2_plc.config(state=tk.DISABLED)

button_cod3_plc = ttk.Combobox(tab12_c3,textvariable=selected_option_cod_plcModus2,width=10,state='readonly')
button_cod3_plc.place(x=300,y=310)
button_cod3_plc.config(state=tk.DISABLED)

button['values']= ('skip','amrnb','amrwb','evs','opus','g711','g722')
button.current(0)

button_cod1_plc['values']= ('-','random','noloss','bursty')
button_cod1_plc.current(0)

button_cod2_plc['values']= ('-','random','noloss','bursty')
button_cod2_plc.current(0)
#button_cod1_plc.bind("<<ComboboxSelected>>", enable_codecs1_plc)

button_cod3_plc['values']= ('-','random','noloss','bursty')
button_cod3_plc.current(0)

button1['values']= ('skip','amrnb','amrwb','evs','opus','g711','g722')
button1.current(0)

button2['values']= ('skip','amrnb','amrwb','evs','opus','g711','g722')
button2.current(0)

# Create the OptionMenu widget
radio_button = ttk.Radiobutton(tab1_filter, text="-", variable=selected_option, value="-", command=on_option_selected,)
radio_button.place(x=145, y=155)

for i, option in enumerate(options):
    radio_button = ttk.Radiobutton(tab1_filter, text=option, variable=selected_option, value=option, command=on_option_selected)
    radio_button.place(x=200+ i * 110 , y=155)


#option_menu.bind("<<ComboboxSelected>>", on_option_selected)
# Place the OptionMenu at a specific location
#option_menu.place(x=70, y=130)
# labels
label1 = ttk.Label(tab1_filter, text="FILTER", style="TLabel").place(x=280, y=50)
label2 = ttk.Label(tab3_arbf, text="ARBITRARY FILTER", style="TLabel").place(x=230, y=50)
label3 = ttk.Label(tab2_timeclp, text="TIME CLIPPING", style="TLabel").place(x=280, y=50)
label4 = ttk.Label(tab5_wbn, text="WHITE BACKGROUND NOISE", style="TLabel").place(x=220, y=50)
label41 = ttk.Label(tab4_clipp, text="CLIPPING", style="TLabel").place(x=280, y=50)
label42 = ttk.Label(tab9_bnf, text="BACKGROUND NOISE FILE", style="TLabel").place(x=180, y=50)
label5 = ttk.Label(tab7_anli, text="ACTIVE SPEECH LEVEL INPUT", style="TLabel").place(x=220, y=50)
label6 = ttk.Label(tab8_anlo, text="ACTIVE SPEECH LEVEL OF DEGRADED OUTPUT", style="TLabel").place(x=130, y=50)
label7 = ttk.Label(tab6_mru, text="MODULATED REFERENCE UNIT", style="TLabel").place(x=220, y=50)
label71 = ttk.Label(tab9_bnf, text="bgn_snr  ->",font=('Calibri New', 10)).place(x=175, y=330)
label51 = ttk.Label(tab5_wbn, text="dB",font=('Calibri New', 10)).place(x=390, y=220)
label51 = ttk.Label(tab6_mru, text="dB",font=('Calibri New', 10)).place(x=390, y=220)
label8 = ttk.Label(tab10_c1, text="SPEECH CODECS 1", style="TLabel").place(x=240, y=50)
label8 = ttk.Label(tab11_c2, text="SPEECH CODECS 2", style="TLabel").place(x=240, y=50)
label8 = ttk.Label(tab12_c3, text="SPEECH CODECS 3", style="TLabel").place(x=240, y=50)
label9 = ttk.Label(root, text="Saved conditions", style="Mess.TLabel").place(x=640, y=20)



entry1 = ValidatedEntryWithPlaceholder(tab1_filter, "0-20000", x=340, y=370, width=12,command=compare_entries,validation_func=custom_validation)
entry2 = ValidatedEntryWithPlaceholder(tab1_filter, "0-20000", x=220, y=370, width=12, command=compare_entries,validation_func=custom_validation)
entry_timclp = ValidatedEntryWithPlaceholder(tab2_timeclp, "", x=405, y=365, validation_func=custom_validationtcfer)
entry_wbng = ValidatedEntryWithPlaceholder(tab5_wbn,"", x=320, y=220, validation_func=custom_validationaslin)
entry_pmnru = ValidatedEntryWithPlaceholder(tab6_mru, "", x= 320, y = 220, validation_func=custom_validationaslin)
entry_aslin = ValidatedEntryWithPlaceholder(tab7_anli, "", x= 320, y = 220, validation_func=custom_validationaslin)
entry_aslout = ValidatedEntryWithPlaceholder(tab8_anlo, "", x= 320, y = 220, validation_func=custom_validationaslin)
entry_bgn2 = ValidatedEntryWithPlaceholder(tab9_bnf, "", x=270, y=330)

   
entry_c1_amnrb = ValidatedEntryWithPlaceholder(tab10_c1, "1-8", x=190, y=240,validation_func=custom_validation_c1amnrb,width=14)
entry_c2_amnrb = ValidatedEntryWithPlaceholder(tab11_c2, "1-8", x=190, y=240,validation_func=custom_validation_c2amnrb,width=14)
entry_c3_amnrb = ValidatedEntryWithPlaceholder(tab12_c3, "1-8", x=190, y=240,validation_func=custom_validation_c3amnrb,width=14)


## messages
style.configure("Mess.TLabel", foreground="grey", padding=(8, 4), font=('Lato', 10, 'bold'))
style.configure("Mes1.TLabel", foreground="black", padding=(8, 4), font=('Verdana', 11, 'bold'))


info_text = "frequency filters allied to signals\nto activate it choose one of the options below"
message = ttk.Label(tab1_filter, text=info_text, style= "Mess.TLabel").place(x=150,y=90)
message1 = ttk.Label(tab1_filter, text=" the bp_low value has to be a natural number \n range from 0 to 20000", style= "Mess.TLabel")
message2 = ttk.Label(tab1_filter, text=" the bp_high value has to be a natural number \n range from 0 to 20000 ", style= "Mess.TLabel")
message3 = ttk.Label(tab1_filter, text=" the bp_high and bb_low value have to be a natural numbers \n range from 0 to 20000 \n bp_low < bp_high ", style= "Mess.TLabel")
message4 = ttk.Label(tab2_timeclp, text=" parts of signal will be cutted in a discontinuous stuttering signal", style= "Mess.TLabel").place(x= 130,y= 90)
message5 = ttk.Label(tab2_timeclp, text="adjust the intensity and duration", style= "Mess.TLabel").place(x= 180,y= 150)
message6 = ttk.Label(tab2_timeclp, text="#frame error rate", style= "Mess.TLabel").place(x= 210,y= 215)
message6 = ttk.Label(tab2_timeclp, text="max. nr. cut frames (positive value)", style= "Mess.TLabel").place(x= 210,y= 340)
message7 = ttk.Label(tab3_arbf, text="an arbitrary frequency filter will be applied", style= "Mess.TLabel").place(x= 165,y= 90)
message8 = ttk.Label(tab5_wbn, text=" noise ratio in dB has to be provided, if wbgn is set", style= "Mess.TLabel").place(x= 165,y= 120)
message8 = ttk.Label(tab6_mru, text="ratio of speech ratio to modulated noise power in dB \nhas to be provided, if MNRU is set", style= "Mess.TLabel").place(x= 120,y= 100)
message9 = ttk.Label(tab10_c1, text="choose the first codec value", style= "Mess.TLabel").place(x= 80,y= 115)
message9 = ttk.Label(tab10_c1, text="set the specific value based BMode1 can have", style= "Mess.TLabel").place(x= 140,y= 200)
message9 = ttk.Label(tab10_c1, text="set second parameter packet loss mode 1", style= "Mess.TLabel").place(x= 260,y= 270)
message9 = ttk.Label(tab10_c1, text="Frame error rate (FER1)", style= "Mess.TLabel").place(x=210,y= 360)
message9 = ttk.Label(tab11_c2, text="choose the second codec value", style= "Mess.TLabel").place(x= 80,y= 115)
message9 = ttk.Label(tab11_c2, text="set the specific value based BMode2 can have", style= "Mess.TLabel").place(x= 140,y= 200)
message9 = ttk.Label(tab11_c2, text="set second parameter packet loss mode 2", style= "Mess.TLabel").place(x= 260,y= 270)
message9 = ttk.Label(tab11_c2, text="Frame error rate (FER2)", style= "Mess.TLabel").place(x=210,y= 360)
message9 = ttk.Label(tab12_c3, text="choose the third codec value", style= "Mess.TLabel").place(x= 80,y= 115)
message9 = ttk.Label(tab12_c3, text="set the specific value based BMode3 can have", style= "Mess.TLabel").place(x= 140,y= 200)
message9 = ttk.Label(tab12_c3, text="set second parameter packet loss mode3", style= "Mess.TLabel").place(x= 260,y= 270)
message9 = ttk.Label(tab12_c3, text="Frame error rate (FER3)", style= "Mess.TLabel").place(x=210,y= 360)
message = ttk.Label(tab7_anli, text="Before applying any degradations active noise level is set", style= "Mess.TLabel").place(x=70,y= 130)
message = ttk.Label(tab7_anli, text="dBo", style= "Mess.TLabel").place(x=390,y= 215)
message = ttk.Label(tab8_anlo, text="dBo", style= "Mess.TLabel").place(x=390,y= 215)
message = ttk.Label(tab4_clipp, text="         clipping threshold", style= "Mess.TLabel").place(x=90,y= 115)
message = ttk.Label(tab4_clipp, text=" signal range is 0 and 1", style= "Mess.TLabel").place(x=170,y= 215)
message = ttk.Label(tab9_bnf, text=" if bgn is set either choose the backgroud noise file", style= "Mess.TLabel").place(x=140,y= 130)
message = ttk.Label(tab9_bnf, text=" or will be chosen randomly", style= "Mess.TLabel").place(x=140,y= 155)
message = ttk.Label(tab9_bnf, text=" click on this entry to choose a noise file", style= "Mess.TLabel").place(x=140,y= 215)
message = ttk.Label(tab9_bnf, text="signal to noise ratio", style= "Mess.TLabel").place(x=170,y= 285)
message = ttk.Label(tab8_anlo, text="After applying all degradations active speech level is set", style= "Mess.TLabel").place(x=70,y= 130)
message = ttk.Label(root, text="Creating conditional tables for the MATLAB database tool", style= "Mes1.TLabel").place(x=70,y= 40)

#### TIMECLIPPINGd

# Create buttons to increase and decrease the value
increase_button = tk.Button(tab2_timeclp, text="+", command=increase_value,width=1, padx=1, pady=1)
increase_button.place(x=475, y=365)

decrease_button = tk.Button(tab2_timeclp, text="-", command=decrease_value,width=1, padx=1, pady=1)
decrease_button.place(x=495, y=365)


def delete_element():
    selected_index = listbox.curselection()  # Get the index of the selected element
    if selected_index:  # Ensure an element is selected
        selected_index = int(selected_index[0])
        listbox.delete(selected_index)  # Delete the selected element from the listbox
        saved_conditions.pop(selected_index)
        update_element_labels(selected_index)  # Update labels of subsequent elements

def update_element_labels(start_index):
    # Update labels of elements following the deleted element
    for i in range(start_index, listbox.size()):
        listbox.delete(i)
        listbox.insert(i, f"Condition {i + 1}") 
        
        
def show_item_content():
    # Get the selected item's index
    
    headers = ['dist_post_codec','filter','timeclipping','wbgn',
              'p50mnru','bgn','bgn_file','clipping','arb_filter',
              'asl_in','asl_out','codec1','codec2','codec3','plcMode1',
              'plcMode2','plcMode3','wbgn_snr','bgn_snr','tc_fer','tc_nburst',
              'cl_th','bp_low','bp_high','p50_q','bMode1','bMode2','bMode3',
              'FER1','FER2','FER3','asl_in_level','asl_out_level','con']  # Example headers

    

    selected_index = listbox.curselection()
    if selected_index:
        index = int(selected_index[0])
        max_header_length = max(len(header) for header in headers)
        message = ""
        content = saved_conditions[index]
        
        for header, value in zip(headers, content):
            message += f"{header.ljust(max_header_length)}: {value}\n"


        messagebox.showinfo("Values", message)
        #messagebox.showinfo("Content", '\n'.join([f"{header}:", f"{content}"]))
        #messagebox.showinfo()


# Create a listbox to display the special list
listbox = tk.Listbox(root, width=30, height=26,relief=tk.RAISED,selectbackground='grey')
listbox.place(x= 640, y=50)

# Create a button to display item content
show_content_button = tk.Button(root, text="Show Content", command=show_item_content)
show_content_button.place(x= 620, y=480)

# Create a button to delete selected item
delete_button = tk.Button(root, text="Delete", command=delete_element)
delete_button.place(x= 720, y=480)
'''
saved_conditions = []
listbox = tk.Listbox(root, width= 30, height=20).place(x= 640, y=50)

# Listbox to display saved conditions
listbox_saved_conditions = tk.Listbox(root, width=30, height=20).place(x= 640, y=50)
# Labels to display saved values
label_saved_value1 = tk.Label(root, text="con1: ").place(x= 640, y=70)
# Labels to display saved values
label_saved_value2 = tk.Label(root, text="con2: ").place(x= 640, y=90)
# Labels to display saved values
'''

saved_conditions = []

header = ['dist_post_codec ', 'filter          ', 'timeclipping   ', 'wbgn           ', 'p50mnru        ', 'bgn            ',
          'bgn_file       ', 'clipping       ', 'arb_filter     ', 'asl_in         ', 'asl_out        ', 'codec1         ',
          'codec2         ', 'codec3         ', 'plcMode1       ', 'plcMode2       ', 'plcMode3       ', 'wbgn_snr       ',
          'bgn_snr        ', 'tc_fer         ', 'tc_nburst      ', 'cl_th          ', 'bp_low         ', 'bp_high        ',
          'p50_q          ', 'bMode1         ', 'bMode2         ', 'bMode3         ', 'FER1           ', 'FER2           ',
          'FER3           ', 'asl_in_level   ', 'asl_out_level  ', 'con            ']

headers = ['dist_post_codec','filter','timeclipping','wbgn',
          'p50mnru','bgn','bgn_file','clipping','arb_filter',
          'asl_in','asl_out','codec1','codec2','codec3','plcMode1',
          'plcMode2','plcMode3','wbgn_snr','bgn_snr','tc_fer','tc_nburst',
          'cl_th','bp_low','bp_high','p50_q','bMode1','bMode2','bMode3',
          'FER1','FER2','FER3','asl_in_level','asl_out_level']  # Example headers

csv_file_name = "output1.csv"

def save_csv():
    # Open file dialog for saving CSV file
    file_path = filedialog.asksaveasfilename(
        defaultextension=".csv",
        filetypes=[("CSV files", "*.csv"), ("All files", "*.*")]
    )
    # Check if the user selected a file path
    if file_path:
        with open(file_path, mode='w', newline='') as file:
            writer = csv.writer(file)
            header_with_con = headers + ["con"]
            writer.writerow(header_with_con)
            # Write saved_conditions along with the "con" column
            for i, condition in enumerate(saved_conditions, start=1):
                writer.writerow(condition + [i])
        # Close the tkinter window
        
        
button = tk.Button(root, text="Add condition", command=get_final_values_filter).place(x= 640,y=540)
button = tk.Button(root, text="Save csv", command=save_csv).place(x= 750,y=540)

reset_button = tk.Button(root, text="Clear", command=clear_values).place(x= 780,y=480)

eng = matlab.engine.start_matlab()

def launch():
        try:
            # Specify the file path
            file_path = r'C:\Users\ervin\Downloads\bt\con_files\test.csv' # Replace with the actual file path
            eng.define_fld(nargout=0)
            
            file_path = filedialog.askopenfilename(title="Select CSV File")
            
            if file_path:
                # If a file is selected, run MATLAB script with the file path argument
                eng.runDatabaseGeneration2(file_path, nargout=0)
            else:
                print("No file selected. Exiting...")
        
        finally:
            eng.quit()
        # Exit the program
            root.destroy()
    

launch_button = tk.Button(root, text="Launch", command= launch).place(x= 700,y=600)

root.mainloop()
