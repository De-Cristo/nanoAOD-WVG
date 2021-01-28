from WMCore.Configuration import Configuration

config = Configuration()

config.section_("General")
config.General.requestName = 'SingleMuon_Run2018A'
config.General.transferLogs= True
config.General.workArea = 'crab2018'

config.section_("JobType")
config.JobType.pluginName = 'Analysis'
config.JobType.psetName = 'PSet.py'
config.JobType.scriptExe = './WZG_crab_script.sh'
config.JobType.inputFiles = ['../../scripts/haddnano.py','./WZG_postproc_data.py','./WZG_Module_data.py','./WZG_input_branch.txt','./WZG_output_branch.txt','../WZG_selector/DAS_filesearch.py'] #hadd nano will not be needed once nano tools are in cmssw
# config.JobType.scriptArgs = ['isdata=1','issignal=0','year=2018']
config.JobType.sendPythonFolder  = True
config.JobType.allowUndistributedCMSSW = True

config.section_("Data")
# config.Data.inputDataset = '/SingleMuon/Run2018A-UL2018_MiniAODv1_NanoAODv2-v1/NANOAOD'
config.Data.inputDataset = '/SingleMuon/Run2018A-02Apr2020-v1/NANOAOD'
#config.Data.inputDBS = 'phys03'
config.Data.inputDBS = 'global'
# config.Data.splitting = 'LumiBased'
config.Data.splitting = 'FileBased'
#config.Data.splitting = 'EventAwareLumiBased'
config.Data.unitsPerJob = 1
config.Data.lumiMask = 'https://cms-service-dqm.web.cern.ch/cms-service-dqm/CAF/certification/Collisions18/13TeV/ReReco/Cert_314472-325175_13TeV_17SeptEarlyReReco2018ABC_PromptEraD_Collisions18_JSON.txt'

config.Data.outLFNDirBase ='/store/user/sdeng/WZG_analysis/data/'
config.Data.publication = False
config.Data.ignoreLocality = True
config.Data.allowNonValidInputDataset = True
config.Data.outputDatasetTag = 'SingleMuon_Run2018A'

config.section_("Site")
config.Site.storageSite = "T3_CH_CERNBOX"
config.Site.whitelist = ['T2_US_MIT','T2_US_Wisconsin','T2_US_Purdue','T2_US_UCSD','T2_US_Caltech','T2_US_Nebraska']