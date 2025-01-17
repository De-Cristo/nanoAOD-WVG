#!/usr/bin/env python
import os, sys
import ROOT
ROOT.PyConfig.IgnoreCommandLineOptions = True
from importlib import import_module
from PhysicsTools.NanoAODTools.postprocessing.framework.postprocessor import PostProcessor
from PhysicsTools.NanoAODTools.postprocessing.modules.common.countHistogramsModule import countHistogramsProducer

from PhysicsTools.NanoAODTools.postprocessing.modules.FakePho_Apply_weight_Template_Module import *

import argparse
import re
import optparse


parser = argparse.ArgumentParser(description='create attachment NanoAOD-like fake photon result')
parser.add_argument('-f', dest='file', default='', help='File input')
args = parser.parse_args()


Modules = [ApplyWeightFakePhotonModule()]
infilelist = [args.file]
jsoninput = None
fwkjobreport = False


p=PostProcessor(".",infilelist,
                branchsel="full_keep_and_drop.txt",
                modules=Modules,
                justcount=False,
                noOut=False,
                fwkJobReport=fwkjobreport, 
                jsonInput=jsoninput, 
                provenance=True,
                outputbranchsel="full_output_branch_selection.txt",
                )
p.run()