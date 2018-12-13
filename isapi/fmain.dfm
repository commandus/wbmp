object WebModule1: TWebModule1
  OldCreateOrder = False
  OnCreate = WebModuleCreate
  OnDestroy = WebModuleDestroy
  Actions = <
    item
      Default = True
      Name = 'WebActionItem1'
      PathInfo = '/2wbmp'
      OnAction = WebModule1WebActionItem1Action
    end
    item
      Name = 'WebActionItem2'
      PathInfo = '/info'
      OnAction = WebModule1WebActionItem2Action
    end>
  Left = 488
  Top = 96
  Height = 150
  Width = 215
end
