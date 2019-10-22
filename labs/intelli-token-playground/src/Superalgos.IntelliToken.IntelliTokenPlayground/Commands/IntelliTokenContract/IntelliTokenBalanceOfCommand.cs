﻿using System;
using System.Collections.Generic;
using System.Numerics;
using System.Text;
using System.Threading.Tasks;
using Superalgos.IntelliToken.IntelliErc20Token;
using Superalgos.IntelliToken.IntelliTokenPlayground.Commands.ContractManagement;
using Superalgos.IntelliToken.IntelliTokenPlayground.Runtime;
using Nethereum.RPC.Eth.DTOs;
using Nethereum.Web3;

namespace Superalgos.IntelliToken.IntelliTokenPlayground.Commands.IntelliTokenContract
{
    public class IntelliTokenBalanceOfCommand : EthInvokeCallFunctionCommand
    {
        public string OwnerAddress { get; set; }

        protected override async Task<object> ExecuteAsync(RuntimeContext context, string contractAddress, Web3 web3)
        {
            var intellitoken = new IntelliTokenV1(contractAddress, web3, context.GasPriceProvider);
            return await intellitoken.BalanceOfAsync(context.ResolveAccountOrContractReference(OwnerAddress));
        }
    }
}