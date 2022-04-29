from __future__ import absolute_import
from __future__ import division
from __future__ import print_function
from __future__ import unicode_literals

import torch
from torch.jit import script, trace
import torch.nn as nn
from torch import optim
import torch.nn.functional as F
import csv
import random
import re
import os
import unicodedata
import codecs
from io import open
import itertools
import math


DEVICE_TYPE = "cpu"
if torch.rocm.is_available():
	DEVICE_TYPE = "rocm"
elif torch.cuda.is_available():
	DEVICE_TYPE = "cuda"

device = torch.device()
