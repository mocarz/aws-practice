import { util } from '@aws-appsync/utils';
import * as ddb from '@aws-appsync/utils/dynamodb';

/**
 * Queries a DynamoDB table for items based on the `id`
 * @param {import('@aws-appsync/utils').Context<{id: string}>} ctx the context
 * @returns {import('@aws-appsync/utils').DynamoDBQueryRequest} the request
 */
export function request(ctx) {
    const user_id = ctx.identity.username
    return ddb.query({
        query: {
            user_id: { eq: user_id }
        },
        projection: ["video_id", "timestamp"]
    });
}

/**
 * Returns the query items
 * @param {import('@aws-appsync/utils').Context} ctx the context
 * @returns {[*]} a flat list of result items
 */
export function response(ctx) {
    if (ctx.error) {
        util.error(ctx.error.message, ctx.error.type);
    }
    return ctx.result;
}
