
/*******************************************************}
{                                                       }
{               Borland DB Web                          }
{           Data aware Web controls                     }
{ Copyright (c) 2003, 2004 Borland Software Corporation }
{                                                       }
{*******************************************************/

using System;
using System.Data;
using System.IO;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Collections;
using System.Collections.Specialized;
using System.ComponentModel;
using System.ComponentModel.Design;
using System.ComponentModel.Design.Serialization;
using System.Drawing;
using System.Drawing.Design;
using System.Text;

namespace Borland.Data.Web
{
	/// <summary>
	///  Data Aware Aggregate Control
	/// </summary>

   public enum AggType
	{
      aggAvg,
      aggCount,
      aggMax,
      aggMin,
      aggSum
   }

	[Designer("Borland.Data.Web.DBWebControlDesigner"),
   ToolboxBitmap(typeof(Borland.Data.Web.DBWebAggregateControl),
	"Borland.Data.Web.DBWebAggregateControl.bmp"),
	ToolboxData("<{0}:DBWebAggregateControl runat=server></{0}:DBWebAggregateControl>")]
   public class DBWebAggregateControl : WebControl, IDBWebColumnLink, IPostBackDataHandler
   {
      private AggType FAggregateType;
      private bool FIgnoreNullValues;
      private const int minWidth = 120;
   	private const string childPrefix = "Ag_";
      private const string defaultTextBoxPortion = "100%";
      private string FTextBoxPortion;
      private LabelPosition FLabelPosition;
      private Label FLabel;
      private System.Web.UI.WebControls.Panel FPanel;
      private Color FCaptionBackColor;
      private Color FCaptionForeColor;
      private DBWebColumnLink FColumnLink;
      private IDBWebColumnLink IColumnLink;
		private TextBox FTextBox;
		private bool FCaptionFontBold;
		private bool FCaptionFontItalic;
		private bool FCaptionFontUnderline;
		private bool FCaptionFontOverline;
		private FontUnit FCaptionFontSize;


   	public DBWebAggregateControl() : base()
      {
      	FTextBox = new TextBox();
         FTextBox.ReadOnly = true;
         FLabel = new Label();
         FPanel = new System.Web.UI.WebControls.Panel();
      	FTextBoxPortion = defaultTextBoxPortion;
         FLabelPosition = LabelPosition.LabelToLeft;
         FColumnLink = new DBWebColumnLink(this);
         IColumnLink = (FColumnLink as IDBWebColumnLink);
         base.Width = new Unit(minWidth);
         // TODO: remove from object inspector
         FAggregateType = AggType.aggAvg;
      }

		protected override void OnInit(EventArgs e)
		{
			base.OnInit(e);
			if( Page != null )
				Page.RegisterRequiresPostBack(this);
      }

      #region IDBWebDataLink
      string IDBWebDataLink.TableName
      {
      	get
         {
         	return IColumnLink.TableName;
         }
         set
         {
         	IColumnLink.TableName = value;
         }
      }
      IDBDataSource IDBWebDataLink.DBDataSource
      {
      	get
         {
         	return IColumnLink .DBDataSource;
         }
         set
         {
         	IColumnLink.DBDataSource = value;
         }
      }
      #endregion
      #region IDBWebColumnLink
      string IDBWebColumnLink.ColumnName
      {
      	get
         {
         	return IColumnLink.ColumnName;
         }
         set
         {
         	IColumnLink.ColumnName = value;
         }
      }
      #endregion

      [Editor(typeof(Borland.Data.Web.TableNamePropEditor), typeof(UITypeEditor)),
		LocalizableCategoryAttribute(DBTypes.sDBWebControl),
		DefaultValue(null)]
	  [LocalizableDescriptionAttribute("TableName")]
      public string TableName
      {
      	get
         {
	      	return IColumnLink.TableName;
         }
      	set
         {
	      	IColumnLink.TableName = value;
         }
      }
		[LocalizableCategoryAttribute(DBTypes.sDBWebControl),
		DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden),
		DefaultValue(null)]
      [LocalizableDescriptionAttribute("DataSource")]
      public IDBDataSource DBDataSource
      {
      	get
         {
         	return IColumnLink.DBDataSource;
         }
         set
         {
         	IColumnLink.DBDataSource = value;
         }
      }


      [Editor(typeof(Borland.Data.Web.ColumnNamePropEditor), typeof(UITypeEditor)),
		LocalizableCategoryAttribute(DBTypes.sDBWebControl),
		DefaultValue(null)]
      [LocalizableDescriptionAttribute("ColumnName")]
      public string ColumnName
      {
      	get
         {
         	return IColumnLink.ColumnName;
         }
         set
         {
         	IColumnLink.ColumnName = value;
         }
      }

		[LocalizableCategoryAttribute(DBTypes.sDBWebControl),
		DefaultValue(AggType.aggAvg)]
      [LocalizableDescriptionAttribute("AggregateType")]
      public AggType AggregateType
      {
         get
         {
            return FAggregateType;
         }
         set
         {
            FAggregateType = value;
         }
      }

		[LocalizableCategoryAttribute(DBTypes.sDBWebControl),
		DefaultValue(false)]
      [LocalizableDescriptionAttribute("IgnoreNullValues")]
      public bool IgnoreNullValues
      {
      	get
         {
         	return FIgnoreNullValues;
         }
         set
         {
         	FIgnoreNullValues = value;
         }
      }

      #region IPostBackDataHandler
      // RaisePostDataChangedEvent is called prior to DataBind()
      // DataSet and related properties are NOT available here
      // Child controls are not available
		bool IPostBackDataHandler.LoadPostData(string postDataKey,
			NameValueCollection postCollection)
      {
         if( this.Visible )
	      	FColumnLink.LoadPostData(postDataKey, postCollection);
         return false;
      }

	   void IPostBackDataHandler.RaisePostDataChangedEvent()
   	{
	   }
      #endregion

		protected override void OnPreRender(EventArgs args)
		{
			base.OnPreRender(args);
			string s = Page.Request.QueryString[DBWebConst.sBorlandImageID];
         if( s != null )
         	return;
         DataBind();
		}

		protected override void Render(HtmlTextWriter output)
		{
      	bool error = ClassUtils.OutputErrors(Page, output, IColumnLink);
         if( !error || (IColumnLink.DBDataSource as DBWebDataSource).ErrorOption != ErrorHtmlOption.logOnErrorPage )
				output.Write(Text);
         else  // if going to a separate error hmtl page, output "OK" button.
         {
         	ClassUtils.OutputOKButton(output);
            Page.Response.End();
         }
		}

		protected string Text
		{
			get
			{
         	StringWriter sw = new StringWriter();
				HtmlTextWriter tw = new HtmlTextWriter(sw);
            ClassUtils.AddStyleToWebControl(FPanel, this.Style);
            FPanel.RenderBeginTag(tw);
            string text = sw.ToString();
            if( ClassUtils.IsEmpty(FLabel.Text) )
            {
            	FTextBox.Width = this.Width;
               FTextBox.Height = this.Height;
            }
            if( FLabelPosition == LabelPosition.LabelAbove ||
            		FLabelPosition == LabelPosition.LabelToLeft )
            {
      			if( !ClassUtils.IsEmpty(FLabel.Text) )
            		FLabel.RenderControl(tw);
            	FTextBox.RenderControl(tw);
            }
            else
            {
            	FTextBox.RenderControl(tw);
      			if( !ClassUtils.IsEmpty(FLabel.Text) )
            		FLabel.RenderControl(tw);
            }
            if( text != null )
            	text = sw.ToString();
            FPanel.RenderEndTag(tw);
            if( text != null )
            	text = sw.ToString();
            return sw.ToString();
			}
		}

      private int PercentValue( string s )
      {
      	try
         {
         	int iPercentPos = s.IndexOf("%" );
            string sNumber = s.Substring(0, iPercentPos);
            int iPercent = Convert.ToInt32(sNumber);
            if( iPercent > 0 && iPercent < 101 )
            	return iPercent;
         }
         catch
         {
         	// invalid percent value: don't use
         }
         return -1;
      }

		#region caption properties
		[LocalizableCategoryAttribute("Caption"),
      DefaultValue("")]
      [LocalizableDescriptionAttribute("CaptionPI")]
      public string Caption
      {
      	get
         {
         	return FLabel.Text;
         }
         set
         {
            if( FLabel.Text != value )
            {
         		FLabel.Text = value;
               if( FTextBoxPortion == defaultTextBoxPortion )
               	FTextBoxPortion = "50%";
            }
         }
      }

		[LocalizableCategoryAttribute("Caption"),
      DefaultValue("LabelPosition.LabelOnTop")]
      [LocalizableDescriptionAttribute("CaptionPosition")]
      public LabelPosition CaptionPosition
      {
      	get
         {
         	return FLabelPosition;
         }
      	set
         {
         	FLabelPosition = value;
         }
      }

		[LocalizableCategoryAttribute("Caption"),
      DefaultValue("100%")]
      [LocalizableDescriptionAttribute("TextBoxPortion")]
      public string TextBoxPortion
      {
      	get
         {
         	return FTextBoxPortion;
         }
      	set
         {
            if( FTextBoxPortion != value )
            {
         		int iPercentPos = value.IndexOf("%" );
            	if( iPercentPos < 0 )
            		value = value + "%";
            	if( PercentValue( value ) != -1 )
          				FTextBoxPortion = value;
            }
         }
      }
		[LocalizableCategoryAttribute("Caption")]
      [LocalizableDescriptionAttribute("CaptionBackColor")]
      public Color CaptionBackColor
      {
      	get
         {
         	return FCaptionBackColor;
         }
         set
         {
         	FCaptionBackColor = value;
         }
      }

		[LocalizableCategoryAttribute("Caption")]
	  [LocalizableDescriptionAttribute("CaptionForeColor")]
	  public Color CaptionForeColor
      {
      	get
         {
         	return FCaptionForeColor;
         }
         set
         {
         	FCaptionForeColor = value;
         }
      }

		[LocalizableCategoryAttribute("Caption")]
      [LocalizableDescriptionAttribute("CaptionFontItalic")]
      public bool CaptionFontItalic
      {
      	get
         {
         	return FCaptionFontItalic;
         }
         set
         {
         	FCaptionFontItalic = value;
         }
      }

		[LocalizableCategoryAttribute("Caption")]
      [LocalizableDescriptionAttribute("CaptionFontUnderline")]
      public bool CaptionFontUnderline
      {
      	get
         {
         	return FCaptionFontUnderline;
			}
			set
			{
				FCaptionFontUnderline = value;
			}
		}
		[LocalizableCategoryAttribute("Caption")]
      [LocalizableDescriptionAttribute("CaptionFontOverLine")]
		public bool CaptionFontOverline
		{
			get
			{
				return FCaptionFontOverline;
			}
			set
			{
				FCaptionFontOverline = value;
			}
		}
		[LocalizableCategoryAttribute("Caption")]
      [LocalizableDescriptionAttribute("CaptionFontSize")]
		public FontUnit CaptionFontSize
		{
			get
			{
				return FCaptionFontSize;
         }
         set
         {
         	FCaptionFontSize = value;
         }
      }

		[LocalizableCategoryAttribute("Caption")]
      [LocalizableDescriptionAttribute("CaptionFontBold")]
      public bool CaptionFontBold
      {
      	get
         {
         	return FCaptionFontBold;
         }
         set
         {
         	FCaptionFontBold = value;
         }
      }
      #endregion

      public string ControlID()
      {
      	return childPrefix + this.ID;
      }

      private void SetControlSize(WebControl control, int portion)
      {
         double divisor = 100 / Convert.ToDouble(portion);
         double dSize;
         if( base.Width.Value < minWidth )
         	base.Width = new Unit(minWidth);
		 dSize = (base.Width.Value / divisor) - ( (2 + base.BorderWidth.Value) * 2);
		 control.Width = new Unit(Math.Floor(dSize));
      }

      private void SetLabelProps( )
      {
	      FLabel.BackColor = FCaptionBackColor;
   	   FLabel.ForeColor = FCaptionForeColor;
      }

      private void SetProportionalSize()
      {

      	int iTextPortion;
         if( FLabelPosition == LabelPosition.LabelAbove ||
         		FLabelPosition == LabelPosition.LabelBelow )
         {
            FPanel.Wrap = true;
			FTextBox.Width = new Unit(base.Width.Value);
         	FLabel.Width = new Unit(base.Width.Value);
         }
         else
         {
            FPanel.Wrap = false;
          	iTextPortion = PercentValue(FTextBoxPortion);
	         if( iTextPortion == -1 )
   	      	iTextPortion = 50;
		      SetControlSize(FTextBox, iTextPortion);
            if( !ClassUtils.IsEmpty(this.Caption) )
		         SetControlSize(FLabel, 100 - iTextPortion);
         }
         SetLabelProps();
      }

      private void SetLabelFont()
      {
      	FLabel.Font.Bold = FCaptionFontBold;
      	FLabel.Font.Italic = FCaptionFontItalic;
      	FLabel.Font.Overline = FCaptionFontOverline;
      	FLabel.Font.Underline = FCaptionFontUnderline;
      	FLabel.Font.Size = FCaptionFontSize;
      }

		public override void DataBind()
      {
      	try
         {
   	   	FTextBox.ID = this.ID;
            base.DataBind();
         	ClassUtils.SetBehaviorProperties(FPanel, this);
	         ClassUtils.SetOuterAppearanceProperties(FPanel, this);
   	      ClassUtils.SetSizeProperties(FPanel, this);
      	   if( !ClassUtils.IsEmpty(FLabel.Text) )
         	{
         		ClassUtils.SetInnerAppearanceProperties(FLabel, this);
	            SetProportionalSize();
               SetLabelFont();
   	         FTextBox.Text = null;
      	   }
      		if( FColumnLink.IsDataBound )
         	{
               ClassUtils.SetBehaviorProperties(FTextBox, this);
               ClassUtils.SetAppearanceProperties(FTextBox, this);
               ClassUtils.SetSizeProperties(FTextBox, this);
            	Object o = IColumnLink.DBDataSource.GetAggregateValue(Page,
            					IColumnLink.TableName, IColumnLink.ColumnName,
                           FAggregateType, FIgnoreNullValues);
               if( o != null )
                  FTextBox.Text = Convert.ToString(o);
               else
                  FTextBox.Text = "";
               FTextBox.DataBind();
            }
         }
         catch(Exception ex)
         {
         	if( !ClassUtils.IsDesignTime(Page) )
            {
	            Page.Response.Write(ClassUtils.GetInternalError(Page, IColumnLink, ex, this.ID));
            }
            else
            	throw new Exception(ex.Message);
         }
      }
   }


}
