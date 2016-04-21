//+--------------------------------------------------------------------+
//| Copyright:  (C) 2016 Forex Software Ltd.                           |
//| Website:    http://forexsb.com/                                    |
//| Support:    http://forexsb.com/forum/                              |
//| License:    Proprietary under the following circumstances:         |
//|                                                                    |
//| This code is a part of Forex Strategy Builder. It is free for      |
//| use as an integral part of Forex Strategy Builder.                 |
//| One can modify it in order to improve the code or to fit it for    |
//| personal use. This code or any part of it cannot be used in        |
//| other applications without a permission.                           |
//| The contact information cannot be changed.                         |
//|                                                                    |
//| NO LIABILITY FOR CONSEQUENTIAL DAMAGES                             |
//|                                                                    |
//| In no event shall the author be liable for any damages whatsoever  |
//| (including, without limitation, incidental, direct, indirect and   |
//| consequential damages, damages for loss of business profits,       |
//| business interruption, loss of business information, or other      |
//| pecuniary loss) arising out of the use or inability to use this    |
//| product, even if advised of the possibility of such damages.       |
//+--------------------------------------------------------------------+

#property copyright "Copyright (C) 2016 Forex Software Ltd."
#property link      "http://forexsb.com"
#property version   "2.00"
#property strict

#include <Forexsb.com/Indicator.mqh>
#include <Forexsb.com/Enumerations.mqh>
#include <Forexsb.com/Indicators/AverageTrueRange.mqh>
//## Requires AverageTrueRange.mqh

class OscillatorofATR : public Indicator
  {
public:
    OscillatorofATR(SlotTypes slotType)
     {
      SlotType=slotType;

      IndicatorName="Oscillator of ATR";

      WarningMessage    = "";
      IsAllowLTF        = true;
      ExecTime          = ExecutionTime_DuringTheBar;
      IsSeparateChart   = true;
      IsDiscreteValues  = false;
      IsDefaultGroupAll = false;
     }

   virtual void Calculate(DataSet &dataSet);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OscillatorofATR::Calculate(DataSet &dataSet)
  {
   Data=GetPointer(dataSet);

// Reading the parameters
   int prvs=CheckParam[0].Checked ? 1 : 0;

// Calculation
   double adOscillator[];
   ArrayResize(adOscillator,Data.Bars);
   ArrayInitialize(adOscillator,0);

// ----------------------------------------------------
   AverageTrueRange *atr1=new AverageTrueRange(SlotType);
   atr1.ListParam[1].Index= ListParam[1].Index;
   atr1.NumParam[0].Value = NumParam[0].Value;
   atr1.CheckParam[0].Checked=CheckParam[0].Checked;
   atr1.Calculate(dataSet);

   AverageTrueRange *atr2=new AverageTrueRange(SlotType);
   atr2.ListParam[1].Index= ListParam[1].Index;
   atr2.NumParam[0].Value = NumParam[1].Value;
   atr2.CheckParam[0].Checked=CheckParam[0].Checked;
   atr2.Calculate(dataSet);

   double adIndicator1[]; 
   ArrayResize(adIndicator1,Data.Bars);
   ArrayCopy(adIndicator1,atr1.Component[0].Value);
   double adIndicator2[];
   ArrayResize(adIndicator2,Data.Bars);
   ArrayCopy(adIndicator2,atr2.Component[0].Value);
// -----------------------------------------------------

   int firstBar=0;
   for(int c=0; c<atr1.Components(); c++)
   {
       if (firstBar<atr1.Component[c].FirstBar)
           firstBar=atr1.Component[c].FirstBar;
       if (firstBar<atr2.Component[c].FirstBar)
           firstBar=atr2.Component[c].FirstBar;
   }
   firstBar+=3;

   for(int bar=firstBar; bar<Data.Bars; bar++)
      adOscillator[bar]=adIndicator1[bar]-adIndicator2[bar];

   delete atr1;
   delete atr2;

// Saving the components
   ArrayResize(Component[0].Value,Data.Bars);
   Component[0].CompName = "Histogram";
   Component[0].DataType = IndComponentType_IndicatorValue;
   Component[0].FirstBar = firstBar;
   ArrayCopy(Component[0].Value,adOscillator);

   ArrayResize(Component[1].Value,Data.Bars);
   Component[1].FirstBar=firstBar;

   ArrayResize(Component[2].Value,Data.Bars);
   Component[2].FirstBar=firstBar;

// Sets the Component's type
   if(SlotType==SlotTypes_OpenFilter)
     {
      Component[1].DataType = IndComponentType_AllowOpenLong;
      Component[1].CompName = "Is long entry allowed";
      Component[2].DataType = IndComponentType_AllowOpenShort;
      Component[2].CompName = "Is short entry allowed";
     }
   else if(SlotType==SlotTypes_CloseFilter)
     {
      Component[1].DataType = IndComponentType_ForceCloseLong;
      Component[1].CompName = "Close out long position";
      Component[2].DataType = IndComponentType_ForceCloseShort;
      Component[2].CompName = "Close out short position";
     }

// Calculation of the logic
   IndicatorLogic indLogic=IndicatorLogic_It_does_not_act_as_a_filter;

   if(ListParam[0].Text=="Oscillator rises")
      indLogic=IndicatorLogic_The_indicator_rises;
   else if(ListParam[0].Text=="Oscillator falls")
      indLogic=IndicatorLogic_The_indicator_falls;
   else if(ListParam[0].Text=="Oscillator is higher than the zero line")
      indLogic=IndicatorLogic_The_indicator_is_higher_than_the_level_line;
   else if(ListParam[0].Text=="Oscillator is lower than the zero line")
      indLogic=IndicatorLogic_The_indicator_is_lower_than_the_level_line;
   else if(ListParam[0].Text=="Oscillator crosses the zero line upward")
      indLogic=IndicatorLogic_The_indicator_crosses_the_level_line_upward;
   else if(ListParam[0].Text=="Oscillator crosses the zero line downward")
      indLogic=IndicatorLogic_The_indicator_crosses_the_level_line_downward;
   else if(ListParam[0].Text=="Oscillator changes its direction upward")
      indLogic=IndicatorLogic_The_indicator_changes_its_direction_upward;
   else if(ListParam[0].Text=="Oscillator changes its direction downward")
      indLogic=IndicatorLogic_The_indicator_changes_its_direction_downward;

   NoDirectionOscillatorLogic(firstBar,prvs,adOscillator,0,Component[1],indLogic);
   ArrayCopy(Component[2].Value,Component[1].Value);
  }
//+------------------------------------------------------------------+
